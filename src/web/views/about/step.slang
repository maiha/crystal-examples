- wiz = ::Data::Wizard.new(config)

.m-3

- unless wiz.valid1
  div class="alert alert-danger" role="alert"
    h5.alert-heading = "Config Error"
    span = "Potential misconfiguration detected. Fix '#{config.source}' and restart #{PROGRAM_NAME}."

#step.container
  p style="vertical-align: middle"

    /// step1
    button#step1-btn.btn.btn-primary aria-controls="step1" aria-expanded="false" data-target="#step1" data-toggle="collapse" type="button" class=wiz.alert1
      .head = config.web_step1_head
      i class=config.web_step1_icon

    /// step2
    i class="fas fa-arrow-right"
    button#step2-btn.btn.btn-primary aria-controls="step2" aria-expanded="false" data-target="#step2" data-toggle="collapse" type="button" class=wiz.alert2
      .head = config.web_step2_head
      i class=config.web_step2_icon

    /// step3
    i class="fas fa-arrow-right"
    button#step3-btn.btn.btn-primary aria-controls="step3" aria-expanded="false" data-target="#step3" data-toggle="collapse" type="button" class=wiz.alert3
      .head = config.web_step3_head
      i class=config.web_step3_icon

    /// step4
    i class="fas fa-arrow-right"
    button#step4-btn.btn.btn-primary aria-controls="step4" aria-expanded="false" data-target="#step4" data-toggle="collapse" type="button" class=wiz.alert4
      .head = config.web_step4_head
      i class=config.web_step4_icon

    /// step5
    i class="fas fa-arrow-right"
    button#step5-btn.btn.btn-primary aria-controls="step5" aria-expanded="false" data-target="#step5" data-toggle="collapse" type="button" class=wiz.alert5
      .head = config.web_step5_head
      i class=config.web_step5_icon

  == slang "about/ws"

  #step1.collapse data-parent="#step" 
    .card.card-body == slang "about/step1"
  #step2.collapse data-parent="#step" 
    .card.card-body == slang "about/step2"
  #step3.collapse data-parent="#step" 
    .card.card-body == slang "about/step3"
  #step4.collapse data-parent="#step" 
    .card.card-body == slang "about/step4"
  #step5.collapse data-parent="#step" 
    .card.card-body == slang "about/step5"

javascript:
  $(function(){
    // highlight code
    $(".crystal-code pre>code").each(function(index, element){
      hljs.highlightBlock(element);
    });

    // Open page of noteworthy step
    var step = '#{wiz.noteworthy_step}';
    $('#' + step + '-btn').focus().click();
  });
