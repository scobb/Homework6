#Name:Steve Cobb
#EID:scc2448

# variables for use in grading
filename='calculator.c'
eid='EID:([a-zA-z][a-zA-Z]*[0-9][0-9]*)'
addcases=('1' '1 1' '-1 -1' '123 456' '12 34 56 78' '1000000 1000000')
addanswers=('1' '2' '-2' '579' '180' '2000000')
multcases=('1' '10 10' '100 100')
multanswers=('1' '100' '10000')

for dir in $(ls); do
    if [[ -d "$dir" ]]; then
        # found a directory -- inspect
        for file in $(ls $dir); do
           if [[ $file = $filename ]]; then
               if [[ `cat $dir/$file` =~ $eid ]]; then
                   this_eid="${BASH_REMATCH[1]}"
	       fi
               echo eid: $this_eid
               gcc $dir/$filename -o$dir/calculator.o
               if [[ $? != 0 ]]; then
                   echo compile failed
               else
                   # run test cases
                   echo compile successful

		   # usages cases
                   usage="$(./$dir/calculator.o)"
                   echo usage statement: $usage

                   # add cases
		   for i in "${!addcases[@]}"; do
                       answer=$(echo "${addcases[$i]}" | ./$dir/calculator.o add)
                       if [[ $answer = ${addanswers[$i]} ]]; then
                           echo got it
                       fi
                   done

		   # mult cases
		   for i in "${!multcases[@]}"; do
                       answer=$(echo "${multcases[$i]}" | ./$dir/calculator.o multiply)
                       if [[ $answer = ${multanswers[$i]} ]]; then
		           echo got it
	               fi
	           done
               fi
	    fi
        done
    fi
done
        
