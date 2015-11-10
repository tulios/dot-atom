# language-babel transpiles run here.
# This runs as a seperate task so that transpiles can have their own environment.
module.exports = (projectPath) ->
  #util = require 'util'
  path = require 'path'
  callback = @async() #async task
  process.chdir(projectPath)
  # require babel-core package for this project
  projectBabelCore = path.normalize( path.join( projectPath, '/node_modules/babel-core'))
  try
    babel = require projectBabelCore
  catch
    # babel core version not found revert to the global
    projectBabelCore = 'babel-core'
    babel = require projectBabelCore

  babelCoreUsed = "Using babel-core at\n#{require.resolve projectBabelCore}"

  process.on 'message', (mObj) ->
    if mObj.command is 'transpile'
      #console.log(util.inspect(process.memoryUsage()));
      babel.transformFile mObj.pathTo.sourceFile, mObj.babelOptions, (err,result) =>
        # fiddly formating a return
        msgRet = {}
        msgRet.reqId = mObj.reqId # send back to reqId
        if err
          msgRet.err = {}
          if err.loc then msgRet.err.loc = err.loc
          if err.codeFrame
            msgRet.err.codeFrame = err.codeFrame
          else msgRet.err.codeFrame = ""
          msgRet.err.message = err.message
        if result
          msgRet.result = result
          msgRet.result.ast = null; # ast seems to create a JSON circular ref on emit
        msgRet.babelVersion = babel.version
        msgRet.babelCoreUsed = babelCoreUsed
        emit "transpile:#{mObj.reqId}", msgRet
    #stop issued
    if mObj.command is 'stop'
      callback()
