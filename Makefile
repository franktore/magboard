SUBSCRIPTION  := xxxx

SECRET := az keyvault secret show --vault-name xxxxx

COLOR_RED := '\033[0;31m'
COLOR_GREEN := '\033[0;32m'
COLOR_NONE := '\033[0m'
MESG_MISSING := "${COLOR_RED}[Missing]${COLOR_NONE}"
MESG_PRESENT := "${COLOR_GREEN}[Present]${COLOR_NONE}"

.PHONY: all help secrets login cache-oauth2 status run run.backend

help:
	@echo "Helper to run app with a sane environment"
	@echo "Valid makefile targets for help or info"
	@echo
	@echo "   help            Show this help screen"
	@echo "   status          Show status of environment variables and files needed"
	@echo
	@echo "Valid targets to obtain credentials and secrets"
	@echo
	@echo "   secrets         Log in to Azure and obtain OAuth2 authentiapption secrets"
	@echo "   login           Log you with Azure in order to access e.g. the Key Vault"
	@echo "   token           Create valid tokens"
	@echo "   cache-oauth2    Get and cache new app OAuth2 secrets from the Key Vault"
	@echo
	@echo "Valid targets to run app"
	@echo
	@echo "   test            Run the unit-test from the CLI"
	@echo "   run             Obtain key vault secrets and start app"
	@echo "   run.backend     Obtain key vault secrets and start app backend only"
	@echo "   run.frontend    Obtain key vault secrets and start app frontend only"
	@echo
	@echo "Typiapplly you want to run 'make secrets' the first time to log into Azure and get available"
	@echo "secrets. Thereafter 'make run' should build and start app (both frontend and backend)."

all: secrets run

status:
	@echo "Command line utilities"
	@make status.utils
	@echo
	@echo "Environment variables"
	@make status.env
	@echo
	@echo "Authentiapption secrets"
	@make status.oauth2

status.utils:
	@echo " Azure CLI :" $(shell (which -s az > /dev/null) && echo ${MESG_PRESENT} || echo ${MESG_PRESENT})
	@echo " jq        :" $(shell (which -s jq > /dev/null) && echo ${MESG_PRESENT} || echo ${MESG_PRESENT})

# status.env:

status.oauth2:
	@echo "  Local .env.oauth2 cache           :" $(shell if [ -f .env.oauth2 ]; then echo ${MESG_PRESENT}; else echo ${MESG_MISSING}; fi)
	@echo "  OAUTH2_PROXY_REDIRECT_URL         :" $(shell if test -f .env.oauth2 && grep -q OAUTH2_PROXY_REDIRECT_URL .env.oauth2 > /dev/null; then grep OAUTH2_PROXY_REDIRECT_URL .env.oauth2 | cut -d= -f2; else echo ${MESG_MISSING}; fi)
	@echo "  OAUTH2_PROXY_CLIENT_SECRET        :" $(shell if test -f .env.oauth2 && grep -q OAUTH2_PROXY_CLIENT_SECRET .env.oauth2 > /dev/null; then echo ${MESG_PRESENT}; else echo ${MESG_MISSING}; fi)
	@echo "  OAUTH2_PROXY_COOKIE_SECRET        :" $(shell if test -f .env.oauth2 && grep -q OAUTH2_PROXY_COOKIE_SECRET .env.oauth2 > /dev/null; then echo ${MESG_PRESENT}; else echo ${MESG_MISSING}; fi)
	@echo "  OAUTH2_PROXY_REDIS_CONNECTION_URL :" $(shell if test -f .env.oauth2 && grep -q OAUTH2_PROXY_REDIS_CONNECTION_URL .env.oauth2 > /dev/null; then echo ${MESG_PRESENT}; else echo ${MESG_MISSING}; fi)
	@echo "  OAUTH2_PROXY_COOKIE_SECURE        :" $(shell if [ -z "${OAUTH2_PROXY_COOKIE_SECURE}" ]; then echo ${MESG_MISSING}; else echo ${OAUTH2_PROXY_COOKIE_SECURE}; fi)


## Logging in to Azure and authentiapption
secrets: login cache-oauth2

login:
	az login --output none
	az account set --subscription $(SUBSCRIPTION)


## RUNNING app
run: .env.oauth2 status
	docker-compose --env-file .env.oauth2 up --build

run.frontend:
	docker-compose up --build frontend

run.backend: .env.oauth2 status
	docker-compose --env-file .env.oauth2 up --build backend


