init: debug version
	apex --env dev -l debug infra init

plan: debug version
	apex --env dev -l debug infra plan

apply: debug version
	apex --env dev -l debug infra apply

deploy: debug version
	apex --env dev -l debug deploy

version:
	terraform version
	apex version

debug:
	export TF_LOG="TRACE"