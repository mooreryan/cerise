#!/bin/bash

printf "hi I'm stdout line 1\n"
>&2 printf "hi I'm stderr line 1\n" 
printf "hi I'm stdout line 2\n"
>&2 printf "hi I'm stderr line 2\n" 
