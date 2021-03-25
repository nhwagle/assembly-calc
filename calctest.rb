#
# Support for automated testing of postfix calculator implementations
# for CSF assignment 2
#

require 'open3'

class CalcTest
	#
	# Run a test.
	#
	# Parameters:
	#   testdir - directory containing the test executable
	#   testexe - the test executable
	#   expected - the expected result of the computation ('ERROR' if an error is expected)
	#   expr - the postfix experssion to test
	#
	# Returns by yielding to a block with the following parameters:
	#   passed - boolean, true if the test passed, false if it failed
	#   msg - descriptive message
	#   out - standard output produced by test
	#   err - standard error output produced by test
	#
	def self.run_test(testdir, testexe, expected, expr)
		out, err, rc = Open3.capture3("cd '#{testdir}' && ./#{testexe} '#{expr}'", :stdin_data => '')

		# Could process be executed?
		if !rc.success? && expected != 'ERROR'
			yield false, 'Test execution failed', out, err
			return
		end

		# Strip error output for consistency with standard output
		err.rstrip!

		# Was there a single line of output?
		out.rstrip!
		if out.include?("\n")
			yield false, 'Program produced more than one line of output', out, err
			return
		end

		# If an error was expected, was it produced?
		if expected == 'ERROR'
			if out.match(/^\s*Error/)
				yield true, 'Program produced expected error', out, err
			else
				yield false, 'Program did not produce expected error', out, err
			end
			return
		end

		# Was the output in the expected format?
		if !(m = out.match(/^\s*Result\s+is\s*:\s*(-?\d+)\s*$/))
			yield false, 'Output was not in the expected format', out, err
			return
		end

		# Did the computed value match the expected value?
		if m[1] != expected
			yield false, 'Output was not correct', out, err
			return
		end

		# Output was correct!
		yield true, 'Output was correct', out, err
	end
end

# vim:ts=2:
