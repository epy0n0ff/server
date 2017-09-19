package main

import (
	"encoding/json"
	"fmt"
	"net/url"
	"os"
	"strconv"
	"time"

	"github.com/apex/go-apex"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/guregu/dynamo"
	"github.com/incident-app-team-a/go-incident/apigateway"
)

type callHistory struct {
	IncidentID int64  `dynamo:"IncidentId" json:"incidentId"`
	CreatedAt  int64  `dynamo:"CreatedAt" json:"createdAt"`
	CognitoID  string `dynamo:"CognitoId" json:"cognitoId"`
	Action     string `dynamo:"Action" json:"Action"`
}

func newCallHistory(req apigateway.Request) (*callHistory, error) {
	params := req.Params.Path.(map[string]interface{})
	body, err := url.ParseQuery(req.BodyJson)
	if err != nil {
		return nil, err
	}
	incidentID, err := strconv.ParseInt(params["incidentId"].(string), 10, 64)
	if err != nil {
		return nil, err
	}

	return &callHistory{
		Action:     body.Get("Event"),
		CognitoID:  params["cognitoId"].(string),
		CreatedAt:  time.Now().Unix(),
		IncidentID: incidentID,
	}, nil
}

func main() {
	region := "ap-northeast-1"
	name := os.Getenv("CALL_HISTORY_TABLE")

	apex.HandleFunc(func(event json.RawMessage, ctx *apex.Context) (interface{}, error) {
		var request apigateway.Request
		if err := json.Unmarshal(event, &request); err != nil {
			fmt.Fprintf(os.Stderr, "unexpected error:%v", err)
			return nil, err
		}

		db := dynamo.New(session.New(), &aws.Config{
			Region: aws.String(region),
		})
		t := db.Table(name)

		evt, err := newCallHistory(request)
		if err != nil {
			fmt.Fprintf(os.Stderr, "unexpected error:%v", err)
			//TODO: エラーモデル返す
			return nil, err
		}
		if err := t.Put(evt).Run(); err != nil {
			fmt.Fprintf(os.Stderr, "unexpected error:%v", err)
			//TODO: エラーモデル返す
			return nil, err
		}

		return evt, nil
	})

}
