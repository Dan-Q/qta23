#!/usr/local/bin/ruby

# Install dependencies
system 'bundle'

# Run server using Passenger, passing control to it
system 'rm -f passenger.3344.pid passenger.3344.pid.lock'
exec 'passenger start --auto --debugger --disable-anonymous-telemetry -p 3344'
