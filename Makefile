
VERB_EXC=../WordNet-3.0/dict/verb.exc
#METHOD_TXT=work/test.txt
METHOD_TXT=work/rt.method.txt
#METHOD_TXT=work/rt.method.defs.txt
PSVERB_TXT=data/powershell-verbs.txt
#PSVERB_TXT=data/powershell-verbs-ext.txt
NVERBS=ruby -rubygems nverbs.rb -v ../WordNet-3.0/dict/index.verb \
            -m ${METHOD_TXT} -p ${PSVERB_TXT}

methods:
	${NVERBS} -c methods
verbs:
	${NVERBS} -c verbs
nonverbs:
	${NVERBS} -c nonverbs
report:
	${NVERBS} -c report
build:
	javac -classpath lib/bcel-5.2.jar -sourcepath src/ -d bin src/Main.java
clean:
	-rm bin/*
.PHONY: clean methods verbs nonverbs