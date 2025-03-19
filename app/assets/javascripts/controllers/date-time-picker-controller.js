import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    const dateTimeOpts = {
      dateFormat: 'dd-mm-yy',
      stepMinute: 15,
      firstDay: 1,
      showButtonPanel: false,
      minDateTime: new Date((new (Date)()).setMinutes(0))
    }

    // Apply date selector to all date inputs
    $(':input.date').datetimepicker(dateTimeOpts)

    $('.all-day:input').change(function () {
      dateTimeOpts.showTimepicker = !$(this).is(':checked')
      dateTimeOpts.timeFormat = ($(this).is(':checked')) ? '' : 'HH:mm'

      $(':input.date').datetimepicker('destroy').datetimepicker(dateTimeOpts)
    })
  }
}
