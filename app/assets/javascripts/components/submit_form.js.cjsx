R = React.DOM

@SubmitForm = React.createClass
  mixins: [React.addons.LinkedStateMixin]

  getInitialState: ->
    text: ''
    comment: ''

  handleSubmit: (e) ->
    e.preventDefault()
    $.ajax
      url: '/main/mypage/submit'
      type: 'POST'
      data: {data_dir: @state.text, comment: @state.comment}
    , 'JSON'

  render: ->
    R.div
      className: 'SubmitForm'
      R.button
        className: 'uk-button uk-button-primary'
        'data-uk-modal': "{target: '#modal'}"
        '戦略提出'
      R.div
        id: 'modal'
        className: 'uk-modal'
        R.div
          className: 'uk-modal-dialog'
          R.form
            method: 'POST'
            onSubmit: @handleSubmit

            R.div
              className: 'SubmitForm'
              R.h3 null, '戦略提出'
              R.table
                className: 'table-base'
                R.tr null,
                  R.th null, '戦略'
                  R.td null,
                    R.textarea
                      id: 'text'
                      valueLink: @linkState('text')
                R.tr null,
                  R.th null, '戦略コメント'
                  R.td null,
                    R.input
                      type: 'text'
                      id: 'comment'
                      valueLink: @linkState('comment')
              R.button
                className: 'btn btn-primary'
                R.i
                  className: 'fa fa-folder-open'
                  '提出'
              R.button
                className: 'btn btn-default'
                'キャンセル'

