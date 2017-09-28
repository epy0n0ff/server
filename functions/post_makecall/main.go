package main

import (
	"encoding/json"
	"os"
	"context"
	"encoding/base64"
	"fmt"
	"net/url"

	"github.com/apex/go-apex"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kms"
	"github.com/incident-app-team-a/go-incident/apigateway"
	"github.com/epy0n0ff/go-plivo"
)

type MakeCallParam struct {
	From       string `json:"from"`
	To         string `json:"to"`
	IncidentID string `json:"incident_id"`
	CognitoID  string `json:"cognito_id"`
}

const region = "ap-northeast-1"

func main() {
	apex.HandleFunc(func(event json.RawMessage, ctx *apex.Context) (interface{}, error) {
		svc := kms.New(session.New(), &aws.Config{
			Region: aws.String(region),
		})

		baseURL, err := decryptEnv(svc, "callback_baseurl")
		if err != nil {
			return nil, err
		}
		authID, err := decryptEnv(svc, "plivo_authid")
		if err != nil {
			return nil, err
		}
		authToken, err := decryptEnv(svc, "plivo_token")
		if err != nil {
			return nil, err
		}

		c, err := plivo.NewClient(string(authID), string(authToken))
		if err != nil {
			fmt.Fprintf(os.Stderr, "unexpected error:%v", err)
			return nil, err
		}

		var req apigateway.Request
		if err := json.Unmarshal(event, &req); err != nil {
			fmt.Fprintf(os.Stderr, "unexpected error:%v", err)
			return nil, err
		}

		var param MakeCallParam
		if err := json.Unmarshal([]byte(req.BodyJson), &param); err != nil {
			fmt.Fprintf(os.Stderr, "unexpected error:%v", err)
			return nil, err
		}
		callbackURL := fmt.Sprintf("%s/%s/%s", string(baseURL), param.IncidentID, param.CognitoID)

		u, err := url.Parse(callbackURL)
		if err != nil {
			fmt.Fprintf(os.Stderr, "unexpected error:%v", err)
			return nil, err
		}
		ops := &plivo.MakeCallOps{
			AnswerMethod:   "POST",
			RingURL:        callbackURL,
			RingMethod:     "POST",
			HangupURL:      callbackURL,
			HangupMethod:   "POST",
			FallbackURL:    callbackURL,
			FallbackMethod: "POST",
		}

		result, err := c.MakeCall(context.Background(), param.From, param.To, u, ops)
		if err != nil {
			fmt.Fprintf(os.Stderr, "unexpected error:%v", err)
			return nil, err
		}

		fmt.Fprintf(os.Stderr, "success:%v", result)
		return nil, nil
	})
}

func decryptEnv(k *kms.KMS, key string) ([]byte, error) {
	env := os.Getenv(key)
	ib, _ := base64.StdEncoding.DecodeString(env)
	input := &kms.DecryptInput{
		CiphertextBlob: []byte(ib),
	}

	result, err := k.Decrypt(input)
	if err != nil {
		fmt.Fprintf(os.Stderr, "unexpected error:%v", err)
		return nil, err

	}
	return result.Plaintext, nil
}
