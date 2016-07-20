$().ready ->
  $(window).on 'resize', Game.alignSpan
  $(window).on 'contextmenu', ->
    return false unless Game.isClickable
    Game.answer2character()
    false
  $(window).on 'click', ->
    if Game.isNextQuestionWait
      Game.isNextQuestionWait = false
      Game.putQuestion()
  Game.startGame()

class Game
  @MOVE_MSEC = 200
  @LIMIT_SEC = 30
  @UPDATE_MSEC = 100

  @questions = []

  @isClickable = false
  @isNextQuestionWait = false

  @timer = false
  @restSec = null
  @level = null

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
    @bodySpan[myIndex].animate(offset, @MOVE_MSEC)
    @answerIndexes.push myIndex

    # 答えが満たされた場合
    if @answerSpan.length is @answerIndexes.length
      console.log @judge()
    else
      Game.se 'push'

  # 解答→文字パレット
  @answer2character:()=>
    # フルで入ってるなら戻さない
    return if @solution.length is @answerIndexes.length

    myIndex = @answerIndexes.length-1
    return if myIndex < 0
    targetIndex = @answerIndexes[myIndex]

    offset = @characterSpan[targetIndex].offset()
    @bodySpan[targetIndex].animate(offset, @MOVE_MSEC)
    @answerIndexes.pop()
    Game.se 'cancel'

  @judge:->
    @stopTimer()
    result = ''
    for index in @answerIndexes
      result += @bodySpan[index].html()
    # 正解
    if result is @solution
      @se 'correct'
      setTimeout (=>
        @isNextQuestionWait = true
      ), 1000
    # 不正解
    else
      @se 'mistake'
      setTimeout @gameover, 1000

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
    $('#timer').html('')

  # 整列
  @alignSpan:=>
    for answerIndex in [0...@answerIndexes.length]
      bodyIndex = @answerIndexes[answerIndex]
      @bodySpan[bodyIndex].offset(Game.answerSpan[answerIndex].offset())
    $('span.character_main').each ->
      index = $(this).data('index')
      return if 0 <= Game.answerIndexes.indexOf(index)
      Game.bodySpan[index].offset(Game.characterSpan[index].offset())

  # ゲームを初期化してスタート
  @startGame:->
    @questions = Utl.shuffle(JSON.parse(JSON.stringify(QUESTIONS)))
    @putQuestion()

  @putQuestion:->
    nextQuestion = @questions.pop()
    @initQuestion nextQuestion.description, nextQuestion.word

  # 問題を出す
  @initQuestion:(description, answer)->
    @description = description
    @solution = answer

    answerArray = Utl.shuffle(answer.split(''))

    @clear()
    $('#description').html(description)
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
        return unless Game.isClickable
        Game.character2answer(@)
      $('body').append(bodySpan)
      bodySpan.offset(@characterSpan[index].offset())
      @bodySpan.push bodySpan

    @startTimer()
    @clickable true

  @clickable:(bool)->
    @isClickable = !!bool

  @startTimer:->
    @stopTimer()
    @restSec = @LIMIT_SEC*1000

    @timer = setInterval(@updateTimer, @UPDATE_MSEC)

  @updateTimer:=>
    @restSec -= @UPDATE_MSEC
    # 時間切れ
    if @restSec <= 0
      @clickable false
      $('#timer').html('0.0')
      @stopTimer()
      @se 'mistake'
      setTimeout @gameover, 1000
    # 時間切れではない
    else
      sec = Math.abs(Math.floor(@restSec/1000))
      float = Math.abs(Math.floor(@restSec/100) % 10)
      $('#timer').html(''+sec+'.'+float)

  @stopTimer:->
    clearInterval @timer if @timer isnt false
    @timer = false

  @se:(filename)->
    aud = new Audio('./audio/'+filename+'.mp3')
    aud.volume = 0.5
    aud.play()

  @gameover:=>
    # 正解に並べ替える
    answerArray = @solution.split('')
    alreadySortedBodySpan = []
    # 既に正しい場所にあるbodySpanは無視する
    for answerIndex in [0...@answerIndexes.length]
      bodySpanIndex = @answerIndexes[answerIndex]
      if answerArray[answerIndex] is @bodySpan[bodySpanIndex].html()
        alreadySortedBodySpan.push bodySpanIndex
    for answerIndex in [0...answerArray.length]
      answerChar = answerArray[answerIndex]
      for bodySpanIndex in [0...@bodySpan.length]
        continue if Utl.inArray bodySpanIndex, alreadySortedBodySpan
        if answerChar is @bodySpan[bodySpanIndex].html()
          offset = @answerSpan[answerIndex].offset()
          @bodySpan[bodySpanIndex].animate(offset, @MOVE_MSEC).addClass 'character_notice'
          alreadySortedBodySpan.push bodySpanIndex
          break
