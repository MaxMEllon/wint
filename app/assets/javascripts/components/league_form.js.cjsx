R = React.DOM

@LeagueForm = React.createClass
  mixins: [React.addons.LinkedStateMixin]

  getInitialState: ->
    name: null
    limit_score: 0
    start_at: new Date($.now()).toLocaleString()
    end_at: new Date($.now()).toLocaleString()
    rule: null
    command: null

  handleSubmit: (e) ->
    e.preventDefault()
    $.ajax
      url: '/admin/leagues/new'
      type: 'POST'
      data:
        name: @state.name
        limit_score: @state.limit_score
        start_at: @state.start_at
        end_at: @state.end_at
        rule: @state.rule
        command: @state.command
    , 'JSON'

  render: ->
    R.div
      className: 'LeagueForm'
      R.button
        className: 'uk-button uk-button-primary'
        'data-uk-modal': "{target: '#modal'}"
        '登録'
      R.div
        id: 'modal'
        className: 'uk-modal'
        R.div
          className: 'uk-modal-dialog'
          R.h3 null, 'リーグ作成'
          R.table
            className: 'table-base'
            R.tr null,
              R.th null, 'リーグ名'
              R.td null,
                R.input
                  type: 'text'
                  id: 'name'
                  valueLink: @linkState('name')
            R.tr null,
              R.th null, '理想得点'
              R.td null,
                R.input
                  type: 'text'
                  id: 'limit_score'
                  valueLink: @linkState('limit_score')
            R.tr null,
              R.th null, '開始'
              R.td null,
                R.input
                  type: 'text'
                  id: 'start_at'
                  valueLink: @linkState('start_at')
            R.tr null,
              R.th null, '終了'
              R.td null,
                R.input
                  type: 'text'
                  id: 'end_at'
                  valueLink: @linkState('end_at')
            R.tr null,
              R.th null, 'ルールファイル'
              R.td null,
                R.input
                  type: 'file'
                  id: 'rule'
                  valueLink: @linkState('rule')
            R.tr null,
              R.th null, 'コンパイルコマンド'
              R.td null,
                R.textarea
                  id: 'command'
                  valueLink: @linkState('command')
          R.button
            className: 'btn btn-primary uk-modal-close'
            onClick: @handleSubmit
            R.i
              className: 'fa fa-folder-open'
              '提出'
          R.button
            className: 'btn btn-default uk-modal-close'
            'キャンセル'

