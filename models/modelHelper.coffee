exports.updateDate = (next) ->
  if @isNew
      @created = new Date()
  @updated = new Date()
  next()
