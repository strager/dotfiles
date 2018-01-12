def fuse_messages:
  reduce .[] as $message (
    [];
    if length > 0 and $message.type == "Comment"
    then
      .[length - 1].descr = .[length - 1].descr + ". " + $message.descr
    else
      . + [$message]
    end
  )
  ;

def format_message_body(severity):
  .loc.source
  + ":" + (.loc.start.line | tostring)
  + ":" + (.loc.start.column | tostring)
  + ": " + severity
  + ": " + .descr
  ;

def format_messages:
  (.[0] | format_message_body("error")),
  (.[1:] | .[] | format_message_body("note"))
  ;

def annotate_messages(annotation):
  .[0].descr = annotation + .[0].descr
  ;

def format_error:
  if has("extra") and (.extra | length) > 0 and (.extra[0] | has("children")) and (.extra[0].children | length) > 0
  then
    .extra[]
    | .message as $parent_messages
    | .children[] | .message
    | annotate_messages($parent_messages[0].descr + " ")
  else
    .message + (if has("extra") then .extra[].message else [] end)
  end
  | fuse_messages | format_messages
  ;

.errors[] | format_error
