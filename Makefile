

SQLY_TEST_HOST?=127.0.0.1
SQLY_TEST_MYSQL_PORT?=3306
SQLY_TEST_PG_PORT?=5432

SQLY_SQLITE_DSN?=./sqlytest.db

.PHONY: usage
usage:
	@echo make test            - runs the targets test_up, test_ test_down in sequence
	@echo   test_up            - starts a test mariadb and postgres environment using docker compose
	@echo   test_              - runs the tests without up/down
	@echo   test_down          - kills and removes the docker compose created environment
	

.PHONY: test
test: test_up test_ test_down
	
	
	
.PHONY: test_up
test_up: testdb_up
	@echo "test_up"
	./_testdb/wait.sh $(SQLY_TEST_HOST) $(SQLY_TEST_MYSQL_PORT)
	./_testdb/wait.sh $(SQLY_TEST_HOST) $(SQLY_TEST_PG_PORT)
	./_testdb/waitlog.sh mysql "ready for connections"
	./_testdb/waitlog.sh postgres "ready to accept connections"
	sleep 5
	@echo "test_up done"
	

test_: export SQLX_SQLITE_DSN=$(SQLY_SQLITE_DSN)
test_: export SQLX_MYSQL_DSN=root:example@tcp($(SQLY_TEST_HOST):$(SQLY_TEST_MYSQL_PORT))/sqlxtest?parseTime=true
test_: export SQLX_POSTGRES_DSN=postgres://postgres:example@$(SQLY_TEST_HOST):$(SQLY_TEST_PG_PORT)/sqlxtest?sslmode=disable
test_: export CGO_ENABLED=1
test_:
	@echo "test_"
	go test -count 1 -v ./...

.PHONY: test_down
test_down: testdb_down
	@echo "test_down"
	
	
.PHONY: testdb_up
testdb_up:
	docker compose -f _testdb/docker-compose.yml up -d
	
.PHONY: testdb_down
testdb_down:
	docker compose -f _testdb/docker-compose.yml rm -fsv
	-rm $(SQLY_SQLITE_DSN)
