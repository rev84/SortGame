$().ready ->
  $(window).on 'resize', Env.onResize
  $(window).on 'contextmenu', ->
    Env.answer2character()
    false


class Env
  @solution = []
  @answerIndexes = []

  @characterSpan = []
  @answerSpan = []
  @bodySpan = []

  # 文字パレット→解答
  @character2answer:(obj)=>
    myIndex = $(obj).data('index')
    return if 0 <= @answerIndexes.indexOf(myIndex)
    targetIndex = @answerIndexes.length

    offset = @answerSpan[targetIndex].offset()
    @bodySpan[myIndex].animate(offset)
    @answerIndexes.push myIndex

  # 解答→文字パレット
  @answer2character:()=>
    myIndex = @answerIndexes.length-1
    return if myIndex < 0
    targetIndex = @answerIndexes[myIndex]

    offset = @characterSpan[targetIndex].offset()
    @bodySpan[targetIndex].animate(offset)
    @answerIndexes.pop()


  @clear:->
    for s in @characterSpan
      s.remove() if s isnt null
    for s in @answerSpan
      s.remove() if s isnt null
    for s in @bodySpan
      s.remove() if s isnt null
    @characterSpan = []
    @answerSpan = []
    @bodySpan = []
    $('#character').html('')
    $('#answer').html('')

  @onResize:=>
    for index in @answerIndexes
      @bodySpan[index].offset(@answerSpan[index].offset()) if index isnt null
    for index in @characterIndexes
      @bodySpan[index].offset(@characterSpan[index].offset()) if index isnt null


initQuestion = (description, answer)->
  Env.description = description
  Env.solution = answer

  answerArray = Utl.shuffle(answer.split(''))

  Env.clear()
  for chara in answerArray
    characterSpan = $('<span>').addClass('character_base character_empty').html('&nbsp')
    answerSpan = $('<span>').addClass('character_base character_empty').html('&nbsp')

    $('#character').append(characterSpan)
    $('#answer').append(answerSpan)

    Env.characterSpan.push characterSpan
    Env.answerSpan.push answerSpan

  for index in [0...answerArray.length]
    bodySpan = $('<span>').addClass('character_base character_main').data('index', index).html(answerArray[index])
    bodySpan.on 'click', ->
      Env.character2answer(@)
    $('body').append(bodySpan)
    bodySpan.offset(Env.characterSpan[index].offset())
    Env.bodySpan.push bodySpan
