command.arguments <- commandArgs(trailingOnly = TRUE);
data.directory    <- normalizePath(command.arguments[1]);
code.directory    <- normalizePath(command.arguments[2]);
output.directory  <- normalizePath(command.arguments[3]);
target.variable   <- command.arguments[4];
target.landcovers <- command.arguments[5];

print( data.directory );
print( code.directory );
print( output.directory );
print( target.variable );
print(target.landcovers)

# print( format(Sys.time(),"%Y-%m-%d %T %Z") );

# start.proc.time <- proc.time();

# # set working directory to output directory
# setwd( output.directory );
