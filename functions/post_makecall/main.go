package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/url"
	"os"

	"github.com/apex/go-apex"
	"github.com/epy0n0ff/go-incident/apigateway"
	"github.com/epy0n0ff/go-plivo"
)

type MakeCallParam struct {
	From       string `json:"from"`
	To         string `json:"to"`
	IncidentID string `json:"incident_id"`
	CognitoID  string `json:"cognito_id"`
}

func main() {
	apex.HandleFunc(func(event json.RawMessage, ctx *apex.Context) (interface{}, error) {
		curl := os.Getenv("callback_url")

		c, err := plivo.NewClient(os.Getenv("plivo_authid"), os.Getenv("plivo_token"))
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
		callbackURL := fmt.Sprintf("%s/%s/%s", curl, param.IncidentID, param.CognitoID)

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
