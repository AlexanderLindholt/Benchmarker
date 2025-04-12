local function difference(a, b)
	if b < a then
		return a - b
	else
		return b - a
	end
end
local function benchmark(funcs, runs)
	if type(runs) ~= "number" or runs <= 1 then runs = nil end
	
	local function measure(func)
		if runs == nil then
			-- Run only once.
			local start = os.clock()
			func()
			return os.clock() - start
		else
			-- Run specified amount of times.
			local sum = 0
			for index = 1, runs, 1 do
				local start = os.clock()
				func()
				sum += os.clock() - start
			end
			return sum/runs -- Calculate average run time.
		end
	end
	
	if #funcs > 1 then
		if #funcs == 2 then
			-- Exactly two functions, so we'll compare them.
			local output = ""
			
			local one = measure(funcs[1])*1000
			local two = measure(funcs[2])*1000
			
			local diff = difference(one, two)
			local fastest = if two < one then two else one
			
			if diff < fastest*0.001 then
				-- Basically identical speeds.
				if two < one then
					output ..= "\n⚖️ Both functions measured at "..tostring(two+diff/2).." milliseconds\n"
				else
					output ..= "\n⚖️ Both functions measured at "..tostring(one+diff/2).." milliseconds\n"
				end
			else
				output ..= "\nFunction 1 measured at "..tostring(one).." milliseconds"
				output ..= "\nFunction 2 measured at "..tostring(two).." milliseconds"
				if two < one then
					output ..= "\n🏆 Function 2 was "..tostring(diff).." milliseconds (~"..tostring(math.round(one/two*100)/100).."x) the speed of function 1\n"
				else
					output ..= "\n🏆 Function 1 was "..tostring(diff).." milliseconds (~"..tostring(math.round(two/one*100)/100).."x) the speed of function 2\n"
				end
			end
			warn(output)
		else
			-- More than 2 functions, so let's measure all.
			local output = ""
			local durations = {}
			local fastest = math.huge -- We'll store the fastest time for comparison.
			local fastestIndex = nil -- We'll store the fastest function's number for later reference.
			for index, func in ipairs(funcs) do -- Use ipairs to ensure only number keys are processed.
				if type(func) ~= "function" then warn("Number "..tostring(index).." is not a function.") continue end -- Ensure it's a function.
				local duration = measure(func)*1000
				if duration < fastest then -- Check if it's faster.
					fastest = duration
					fastestIndex = index
				end
				table.insert(durations, duration)
			end
			for index, duration in durations do
				output ..= "\nFunction "..tostring(index).." measured at "..tostring(duration).." milliseconds"
				if index ~= fastestIndex then
					output ..= " — ~"..tostring(math.round(fastest/duration*100)/100).."x the speed of function "..tostring(fastestIndex)
				end
			end
			output ..= "\n🏆 Function "..tostring(fastestIndex).." was the fastest\n"
			warn(output)
		end
	else
		-- Single function.
		local func = funcs[1]
		if type(func) ~= "function" then warn("Provided is not a function.") return end -- Ensure it's a function.
		warn("Function measured at "..tostring(measure(func)*1000).." milliseconds")
	end
end

benchmark(
	{ -- Functions to benchmark.
		function()
			
		end,
	},
	100 -- Runs (higher is more accuracy, but takes longer).
)
