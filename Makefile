REBAR = rebar
DIALYZER = dialyzer

DIALYZER_WARNINGS = -Wunmatched_returns -Werror_handling \
                    -Wrace_conditions -Wunderspecs 

.PHONY: all compile test qc clean dialyze deps

all: compile

compile:
	@$(REBAR) compile

test: compile
	@$(REBAR) eunit skip_deps=true

qc: compile
	@$(REBAR) qc skip_deps=true

clean:
	@$(REBAR) clean


dialyze: 
	@$(DIALYZER) --src -r src -pa ebin --fullpath  $(DIALYZER_WARNINGS) 
