.PHONY: test

iex: 
	iex -S mix

install:
	mix deps.get

test:
	mix test

test.wip:
	mix test --only wip

test.wip.iex:
	iex -S mix test --only wip 

ci.test:
	@make install
	@make test
	MIX_ENV=dev mix credo list --strict --format=oneline
	MIX_ENV=dev mix dialyzer --format short