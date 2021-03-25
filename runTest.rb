#! /usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'calctest'

# Run one test of the postfix calculator.
# Exits with a success (0) exit code IFF the specified test passes.

def usage
	puts "Usage: ./runTest.rb [-v] <calculator exe> <expected result> <expr>"
	puts "  -v option prints verbose output if test fails"
	puts "  If <expected result> is ERROR, then an error is expected"
	exit 1
end

verbose = false
if ARGV.length > 0 && ARGV[0] == '-v'
	verbose = true
	ARGV.shift
end

usage() if ARGV.length != 3

calc_exe = ARGV.shift
expected_result = ARGV.shift
expr = ARGV.shift

CalcTest.run_test('.', calc_exe, expected_result, expr) do |passed, msg, out, err|
	print "Testing that #{expr} yields #{expected_result}..."
	STDOUT.flush()
	if passed
		puts "PASSED"
		exit 0
	else
		puts "FAILED (#{msg})"
		if verbose
			puts "Standard output was:\n#{out}\n"
			puts "Standard error was:\n#{err}\n"
		end
		exit 1
	end
end

# vim:ts=2:
