#Name:Steve Cobb
#EID:scc2448

# variables for use in grading
filename='calculator.c'
eid='EID:([a-zA-z][a-zA-Z]*[0-9][0-9]*)'
addcases=('1' '1 1' '-1 -1' '123 456' '12 34 56 78' '1000000 1000000')
addanswers=('1' '2' '-2' '579' '180' '2000000')
multcases=('1' '10 10' '100 100')
multanswers=('1' '100' '10000')
main='[[:space:]]*int[[:space:]][[:space:]]*main'
commentregex='[[:space:]]*//.*'
grader_comments=''
prefix=''
usage_word=('add', 'multiply', 'Usage', 'calculate')

for dir in $(ls); do
    if [[ -d "$dir" ]]; then
        # found a directory -- inspect
        for file in $(ls $dir); do
           if [[ $file = $filename ]]; then
               if [[ `cat $dir/$file` =~ $eid ]]; then
                   this_eid="${BASH_REMATCH[1]}"
	       fi
               echo eid: $this_eid
               if [[ -z $this_eid ]]; then
                   resp=$dir
	       else
                   resp=$this_eid
               fi	
 	       # comment check
	       comments=0
	       pre_main_flag=false
	       while read p; do
                   if [[ $p =~ $commentregex ]]; then
                       let "comments = comments + 1"
                   fi
		   if [[ $p =~ $main ]]; then
                       if [[ $prev =~ $commentregex ]]; then
                           pre_main_flag=true
                       fi
                   fi
                   prev=$p
	       done < $dir/$file
                   
	       # compile
               gcc $dir/$filename -o$dir/calculator.o
               if [[ $? != 0 ]]; then
		   # compile check
                   grader_comments=$prefix$grader_commentscompile failed
		   prefix=';'
		   score=0
               else
		   score=10
                   # run test cases
                   echo compile successful

		   # usages cases
                   correct_usage=true
                   test_usage="$(./$dir/calculator.o)"
                   for word in $usage_words; do
                       if [[ $test_usage != *$word* ]]; then
			   echo $word not in $test_usage
			   correct_usage=false
   			   break;
                       fi
                   done

		   echo correct_usage: $correct_usage

                   # add cases
		   for i in "${!addcases[@]}"; do
                       answer=$(echo "${addcases[$i]}" | ./$dir/calculator.o add)
                       if [[ $answer != ${addanswers[$i]} ]]; then
                           let "score = score - 1"
                       fi
                   done

		   # mult cases
		   for i in "${!multcases[@]}"; do
                       answer=$(echo "${multcases[$i]}" | ./$dir/calculator.o multiply)
                       if [[ $answer != ${multanswers[$i]} ]]; then
		           let "score = score - 1"
	               fi
	           done
                   echo score after add, mult: $score
               fi
               resp=$resp,$score
               if [[ $comments > 2 ]] && [[ $pre_main_flag = true ]]; then
                   resp=$resp,ok
               else
                   resp=$resp,notok
               fi
               echo resp: $resp
	    fi
        done
    fi
done
        
