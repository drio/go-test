# vim: set foldmethod=indent foldlevel=0:
ENV?=staging
DOMAIN?=drtufts.net
EC2_IP?=
REMOTE_DIR=/home/ec2-user/services
SERVICE_NAME=gotestapp
REMOTE_SERVICE_DIR=$(REMOTE_DIR)/$(SERVICE_NAME)

URL=https://$(ENV).$(DOMAIN)
EC2_USER?=ec2-user
EC2_CER?=~drio/.ssh/drio_aws_tufts.cer

SSH=ssh -i $(EC2_CER) $(EC2_USER)@$(EC2_IP) 


## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

## dev: run dev
.PHONY: dev
run:
	go run *.go

## ssh: ssh to instance
.PHONY: ssh
ssh:
	$(SSH)

## rsync: rsync code to machine
.PHONY: rsync
rsync: remote/mkdir
	rsync -avz \
		-e "ssh -i $(EC2_CER)" \
		--exclude=src/server \
		.  $(EC2_USER)@$(EC2_IP):$(REMOTE_SERVICE_DIR)

## deploy: deploy new code and restart server
.PHONY: deploy
deploy: rsync
	$(SSH) "cd $(REMOTE_SERVICE_DIR) && make service/restart"

## remote/mkdir
.PHONY: remote/mkdir
remote/mkdir:
	$(SSH) "mkdir -p $(REMOTE_SERVICE_DIR)"

## remote/service/status: service status
.PHONY: remote/service/status
remote/service/status:
	$(SSH) "systemctl status goserver"

## remote/service/%: install service on remote machine env=(prod, staging)
.PHONY: remote/service/install
remote/service/install:
	$(SSH) "cd $(REMOTE_SERVICE_DIR) && sudo make service/install ENV=$(ENV)"

## remote/service/install: uninstall/remove service from remote machine
.PHONY: remote/service/uninstall
remote/service/uninstall:
	$(SSH) "cd $(REMOTE_SERVICE_DIR) && sudo make service/uninstall"

## remote/service/tail: tail logs
.PHONY: remote/service/tail
remote/service/tail:
	$(SSH) "cd $(REMOTE_SERVICE_DIR) && sudo make service/tail"

## remote/service/restart: restart service
.PHONY: remote/service/restart
remote/service/restart:
	$(SSH) "cd $(REMOTE_SERVICE_DIR) && sudo make service/tail"


## service/install: install the systemd service on current machine
.PHONY: service/install
service/install:
	cat ./service/$(SERVICE_NAME).service > /lib/systemd/system/$(SERVICE_NAME).service && \
	chmod 644 /lib/systemd/system/$(SERVICE_NAME).service && \
	systemctl daemon-reload && \
	systemctl enable $(SERVICE_NAME) && \
	systemctl restart $(SERVICE_NAME)

## service/uninstall: uninstall the systemd service on current machine
.PHONY: service/uninstall
service/uninstall:
	sudo systemctl stop goserver
	sudo systemctl disable goserver.service
	sudo rm -rf /etc/systemd/system/goserver.service /etc/systemd/user/goserver.service

## service/restart: restart service
.PHONY: service/restart
service/restart:
	sudo systemctl restart $(SERVICE_NAME).service

## service/tail: tail
.PHONY: service/tail
service/tail:
	journalctl -u $(SERVICE_NAME)	 | tail

mod: go.mod

go.mod:
	go mod init github.com/drio/go-test
