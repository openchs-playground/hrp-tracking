# <makefile>
# Objects: refdata, package
# Actions: clean, build, deploy
help:
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
	for help_line in $${help_lines[@]}; do \
	    IFS=$$'#' ; \
	    help_split=($$help_line) ; \
	    help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
	    help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
	    printf "%-30s %s\n" $$help_command $$help_info ; \
	done
# </makefile>


port:= $(if $(port),$(port),8021)
server:= $(if $(server),$(server),http://localhost)

su:=$(shell id -un)

auth:
	$(if $(poolId),$(eval token:=$(shell node scripts/token.js $(poolId) $(clientId) $(username) $(password))))

create_org:
	psql -U$(su) openchs < create_organisation.sql

deploy_common_concept:
	curl -X POST $(server):$(port)/concepts -d @../openchs-client/packages/openchs-health-modules/health_modules/commonConcepts.json -H "Content-Type: application/json" -H "ORGANISATION-NAME: OpenCHS" -H "AUTH-TOKEN: $(token)"

## <refdata>
deploy_refdata: ## Creates reference data by POSTing it to the server
	curl -X POST $(server):$(port)/catchments -d @catchments.json -H "Content-Type: application/json" 	-H "ORGANISATION-NAME: HRP Tracking"  -H "AUTH-TOKEN: $(token)"
	curl -X POST $(server):$(port)/concepts -d @concepts.json -H "Content-Type: application/json" 	-H "ORGANISATION-NAME: HRP Tracking" -H "AUTH-TOKEN: $(token)"
	curl -X POST $(server):$(port)/forms -d @registrationForm.json -H "Content-Type: application/json" -H "ORGANISATION-NAME: HRP Tracking" -H "AUTH-TOKEN: $(token)"
	curl -X POST $(server):$(port)/forms -d @encounterForm.json -H "Content-Type: application/json" -H "ORGANISATION-NAME: HRP Tracking" -H "AUTH-TOKEN: $(token)"
	
## </refdata>

deploy: auth deploy_refdata