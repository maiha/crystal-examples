/ env.notices : Array(String | Try(String))
- if (notices = env.notices).any?
  .row_n
    .flex_item
      - notices.each do |msg|
        - case msg
        - when String
          .notice.notice_message
            span.notice_icon Icon
            pre= msg
        - when Success(String)
          .notice.notice_success
            span.notice_icon Icon
            pre= msg.as(Success(String)).get
        - when Failure(String)
          .notice.notice_failure
            span.notice_icon Icon
            pre= msg.as(Failure(String)).err.to_s
        - else
          .notice.notice_failure
            span.notice_icon Icon
            pre.notice_error= "[BUG] (got #{msg.class})\n#{msg}"
