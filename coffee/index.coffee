$().ready ->
  $(window).on 'resize', Game.alignSpan
  $(window).on 'contextmenu', ->
    Game.answer2character()
    false


class Game
  @solution = []
  @description = null
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
    @bodySpan[myIndex].animate(offset, 200)
    @answerIndexes.push myIndex

    # 答えが満たされた場合
    if @answerSpan.length is @answerIndexes.length
      console.log @judge()

  # 解答→文字パレット
  @answer2character:()=>
    myIndex = @answerIndexes.length-1
    return if myIndex < 0
    targetIndex = @answerIndexes[myIndex]

    offset = @characterSpan[targetIndex].offset()
    @bodySpan[targetIndex].animate(offset, 200)
    @answerIndexes.pop()

  @judge:->
    result = ''
    for index in @answerIndexes
      result += @bodySpan[index].html()
    result is @solution

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
    @answerIndexes = []
    @description = null
    $('#description').html('')
    $('#character').html('')
    $('#answer').html('')

  # 整列
  @alignSpan:=>
    for answerIndex in [0...@answerIndexes.length]
      bodyIndex = @answerIndexes[answerIndex]
      @bodySpan[bodyIndex].offset(Game.answerSpan[answerIndex].offset())
    $('span.character_main').each ->
      index = $(this).data('index')
      return if 0 <= Game.answerIndexes.indexOf(index)
      Game.bodySpan[index].offset(Game.characterSpan[index].offset())


  @initQuestion:(description, answer)->
    @description = description
    @solution = answer

    answerArray = Utl.shuffle(answer.split(''))

    @clear()
    for chara in answerArray
      characterSpan = $('<span>').addClass('character_base character_empty').html('&nbsp')
      answerSpan = $('<span>').addClass('character_base character_empty').html('&nbsp')

      $('#character').append(characterSpan)
      $('#answer').append(answerSpan)

      @characterSpan.push characterSpan
      @answerSpan.push answerSpan

    for index in [0...answerArray.length]
      bodySpan = $('<span>').addClass('character_base character_main').data('index', index).html(answerArray[index])
      bodySpan.on 'click', ->
        Game.character2answer(@)
      $('body').append(bodySpan)
      bodySpan.offset(@characterSpan[index].offset())
      @bodySpan.push bodySpan
