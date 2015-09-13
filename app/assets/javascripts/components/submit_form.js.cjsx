R = React.DOM

class @SubmitForm extends React.Component
  render: ->
    R.div className: 'SubmitForm',
      R.h3 null, '戦略提出'
      R.table className: 'table-base',
        R.tr null,
          R.th null, '戦略'
          R.td null,
            R.textarea id: 'text', null
        R.tr null,
          R.th null, '戦略コメント'
          R.td null,
            R.input {type: 'text', id: 'comment'}, null
      R.button className: 'btn btn-primary',
        R.i className: 'fa fa-folder-open', '提出'
      R.button className: 'btn btn-default', 'キャンセル'

