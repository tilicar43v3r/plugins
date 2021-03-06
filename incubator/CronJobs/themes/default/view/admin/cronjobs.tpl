
<link href="/CronJobs/themes/default/assets/css/cronjobs.css?v={CRONJOBS_ASSET_VERSION}" rel="stylesheet">
<div id="page">
	<p class="hint">
		<?= self::escapeHtml(tr('Interface from which you can add your cron jobs. This interface is for administrators only. Customers have their own interface which is more restricted.', true));?>
	</p>
	<br />
	<div class="static_warning">
		<?=
			self::escapeHtml(
				tr(
					'Configuring cron jobs requires distinct knowledge of the crontab syntax on Unix based systems. More information about this topic can be obtained on the following webpage:', true
				)
			) . ' <a target="_blank" href="http://www.unixgeeks.org/security/newbie/unix/cron-1.html"><strong>' . self::escapeHtml(tr('Newbie: Intro to cron', true)) . '</strong></a>';
		?>
	</div>
	<table class="datatable">
		<thead>
		<tr>
			<th style="width:10%"><?= self::escapeHtml(tr('Type', true));?></th>
			<th style="width:15%"><?= self::escapeHtml(tr('Time/Date', true));?></th>
			<th style="width:15%"><?= self::escapeHtml(tr('User', true));?></th>
			<th style="width:40%"><?= self::escapeHtml(tr('Command', true));?></th>
			<th style="width:10%"><?= self::escapeHtml(tr('Status', true));?></th>
			<th style="width:10%"><?= self::escapeHtml(tr('Actions', true));?></th>
		</tr>
		</thead>
		<tfoot>
		<tr>
			<td><?= self::escapeHtml(tr('Type', true));?></td>
			<td><?= self::escapeHtml(tr('Time/Date', true));?></td>
			<td><?= self::escapeHtml(tr('User', true));?></td>
			<td><?= self::escapeHtml(tr('Command', true));?></td>
			<td><?= self::escapeHtml(tr('Status', true));?></td>
			<td><?= self::escapeHtml(tr('Actions', true));?></td>
		</tr>
		</tfoot>
		<tbody>
		<tr>
			<td colspan="6"><?= self::escapeHtml(tr('Loading data...', true));?></td>
		</tr>
		</tbody>
		<tbody>
		<tr>
			<td colspan="7" style="background-color: #b0def5">
				<div class="buttons">
					<button data-action="add_cronjob_dialog">
						<strong><?= self::escapeHtml(tr('Add cron job', true));?></strong>
					</button>
				</div>
			</td>
		</tr>
		</tbody>
	</table>
	<div id="dialog_frm">
		<form name="cron_job_frm" id="cron_job_frm">
			<table class="firstColFixed">
				<tbody>
				<tr>
					<td><label for="cron_job_notification"><?= self::escapeHtml(tr('Email', true));?></label></td>
					<td>
						<input type="text" name="cron_job_notification" id="cron_job_notification" value="{DEFAULT_EMAIL_NOTIFICATION}">
						<div>
							<small><?= self::escapeHtml(tr('Email to which cron notifications must be sent if any. Leave blank to disable notifications.', true));?></small>
						</div>
					</td>
				</tr>
				<tr>
					<td><label for="cron_job_minute"><?= self::escapeHtml(tr('Minute', true));?></label></td>
					<td>
						<input type="text" name="cron_job_minute" id="cron_job_minute" value="*">
						<div><small><?= self::escapeHtml(tr('Minute at which the cron job must be executed.', true));?></small></div>
					</td>
				</tr>
				<tr>
					<td><label for="cron_job_hour"><?= self::escapeHtml(tr('Hour', true));?></label></td>
					<td>
						<input type="text" name="cron_job_hour" id="cron_job_hour" value="*">
						<div><small><?= self::escapeHtml(tr('Hour at which the cron job must be executed.', true));?></small></div>
					</td>
				</tr>
				<tr>
					<td><label for="cron_job_dmonth"><?= self::escapeHtml(tr('Day of month', true));?></label></td>
					<td>
						<input type="text" name="cron_job_dmonth" id="cron_job_dmonth" value="*">
						<div><small><?= self::escapeHtml(tr('Day of the month at which the cron job must be executed.', true));?></small></div>
					</td>
				</tr>
				<tr>
					<td><label for="cron_job_month"><?= self::escapeHtml(tr('Month', true));?></label></td>
					<td>
						<input type="text" name="cron_job_month" id="cron_job_month" value="*">
						<div><small><?= self::escapeHtml(tr('Month at which the cron job must be executed.', true));?></small></div>
					</td>
				</tr>
				<tr>
					<td><label for="cron_job_dweek"><?= self::escapeHtml(tr('Day of week', true));?></label></td>
					<td>
						<input type="text" name="cron_job_dweek" id="cron_job_dweek" value="*">
						<div><small><?= self::escapeHtml(tr('Day of the week at which the cron job must be executed.', true));?></small></div>
					</td>
				</tr>
				<tr>
					<td><label for="cron_job_user"><?= self::escapeHtml(tr('User', true));?></label></td>
					<td>
						<input type="text" name="cron_job_user" id="cron_job_user" value="root">
						<div><small><?= self::escapeHtml(tr('User under which the cron job must be executed.', true));?></small></div>
					</td>
				</tr>
				<tr>
					<td><label for="cron_job_command"><?= self::escapeHtml(tr('Command', true));?></label></td>
					<td>
						<input type="text" name="cron_job_command" id="cron_job_command" class="inputTitle" placeholder="<?= self::escapeHtmlAttr(tr('Command to execute...', true));?>">
					</td>
				</tr>
				<tr>
					<td>
						<label for="cron_job_type">
							<?= self::escapeHtml(tr('Command type', true));?>
							<span class="icon i_help" title="<?= self::escapeHtmlAttr(tr('Url commands are run via GNU Wget while shell commands are run via shell command interpreter (eg. Dash, Bash...).', true));?>">&nbsp;</span>
						</label>
					</td>
					<td>
						<select name="cron_job_type" id="cron_job_type">
							<option value="url"><?= self::escapeHtml(tr('Url', true));?></option>
							<option value="full"><?= self::escapeHtml(tr('Shell', true));?></option>
						</select>
					</td>
				</tr>
				</tbody>
			</table>
			<input type="hidden" id="cron_job_id" name="cron_job_id" value="0" tabindex="-1">
		</form>
		<div class="static_info">
			<ul>
				<li>
					<?=
						self::escapeHtml(
							tr(
								'You can learn more about the syntax by reading:', true
							)
						) . ' <a target="_blank" href="http://www.unixgeeks.org/security/newbie/unix/cron-1.html" tabindex="-1"><strong>' . self::escapeHtml(tr('Newbie: Intro to cron', true)) . '</strong></a>';
					?>
				</li>
				<li><?= self::escapeHtml(tr('When using a shortcut in the minute time field, all other time/date fields are ignored.', true));?></li>
				<li><?= self::escapeHtml(tr('The available shortcuts are: @reboot, @yearly, @annually, @monthly, @weekly, @daily, @midnight and @hourly', true));?></li>
			</ul>
		</div>
	</div>
</div>
<script>
	$(function() {
		var $dataTable, $dialog, flashMessagesTarget;

		function flashMessage(type, message) {
			var target = (flashMessagesTarget) ? flashMessagesTarget : ".body";
			$("<div>", { "class": "flash_message " + type, "html": $.parseHTML(message), "hide": true }).
				prependTo(target).trigger('message_timeout');
		}

		function doRequest(rType, action, data) {
			return $.ajax({
				dataType: "json",  type: rType,  url: "/admin/cronjobs?action=" + action,  data: data,  timeout: 5000
			});
		}

		function handleTimedateInputs(val) {
			var $els = $("#cron_job_hour,#cron_job_dmonth,#cron_job_month,#cron_job_dweek");

			if($.inArray(val, ['@reboot', '@yearly', '@annually', '@monthly', '@weekly', '@daily', '@midnight', '@hourly']) >= 0) {
				$els.val("").prop("readonly", true).attr('tabindex', -1);
			} else {
				$els.prop("readonly", false);
				$els.each(function() {
					if($(this).val() === '') {
						$(this).val("*");
					}
				});

				$(":input:visible").each(function(i,e) { $(e).attr("tabindex", i); });
			}
		}

		jQuery.fn.dataTableExt.oApi.fnProcessingIndicator = function (settings, onoff) {
			if (typeof(onoff) == "undefined") {
				onoff = true;
			}

			this.oApi._fnProcessingDisplay(settings, onoff);
		};

		$dataTable = $(".datatable").dataTable({
			language: {DATATABLE_TRANSLATIONS},
			displayLength: 5,
			processing: true,
			serverSide: true,
			pagingType: "simple",
			ajaxSource: "/admin/cronjobs?action=get_cronjobs_list",
			stateSave: true,
			columnDefs: [ { sortable: false, searchable: false, targets: [ 4, 5 ] } ],
			columns: [
				{ data: "cron_job_type" },
				{ data: "cron_job_timedate" },
				{ data: "cron_job_user" },
				{ data: "cron_job_command" },
				{ data: "cron_job_status" },
				{ data: "cron_job_actions" }
			],
			serverData: function (source, data, callback) {
				$.ajax({
					dataType: "json",
					type: "GET",
					url: source,
					data: data,
					success: callback,
					timeout: 3000
				}).done(function () {
					$dataTable.find("span").tooltip({ tooltipClass: "ui-tooltip-notice", track: true });
				}).fail(function(jqXHR) {
					$dataTable.fnProcessingIndicator(false);
					flashMessage('error', $.parseJSON(jqXHR.responseText).message);
				});
			}
		});

		$dialog = $("#dialog_frm").dialog({
			autoOpen: false,
			show: "blind",
			hide: "blind",
			height: "auto",
			width: "50%",
			modal: true,
			title: "<?= self::escapeJs(tr('Add / Edit Cron job', true));?>",
			buttons: [
				{
					text: "<?= self::escapeJs(tr('Save', true));?>",
					"data-action": "add_cronjob"
				},
				{
					text: "<?= self::escapeJs(tr('Cancel', true));?>",
					click: function () {
						$dialog.dialog("close");
					}
				}
			],
			open: function() {
				flashMessagesTarget = "#dialog_frm";
			},
			close: function() {
				$("form")[0].reset();
				$("#dialog_frm.flash_message").remove();
				flashMessagesTarget = undefined;
			}
		});

		$("body").
			on('keyup', "#cron_job_minute", function() { handleTimedateInputs($(this).val()); }).
			on("reset", "form", function () {
				$("input:hidden").val("0");
				$("#cron_job_hour,#cron_job_dmonth,#cron_job_month,#cron_job_dweek,#cron_job_user").prop("readonly", false);
				$(":input:visible").each(function(i,e) { $(e).attr("tabindex", i); });
			}).
			on("click", "span[data-action]", function () { $("form")[0].reset(); }).
			on("click", "span[data-action],button[data-action]", function (e) {
				$("button").blur();
				e.preventDefault();

				var action = $(this).data('action');

				switch (action) {
					case "add_cronjob_dialog":
						$dialog.dialog("open");
						break;
					case "add_cronjob":
						doRequest('POST', action, $("#cron_job_frm").serialize()).done(function (data) {
							$dialog.dialog("close");
							flashMessagesTarget = undefined;
							flashMessage('success', data.message);
							$dataTable.fnDraw();
						});
						break;
					case "edit_cronjob":
						doRequest(
							"GET", "get_cronjob", { cron_job_id: $(this).data('cron-job-id') }
						).done(function (data) {
							$("#cron_job_notification").val(data.cron_job_notification);
							var $cronJobMinute = $("#cron_job_minute").val(data.cron_job_minute);
							$("#cron_job_hour").val(data.cron_job_hour);
							$("#cron_job_dmonth").val(data.cron_job_dmonth);
							$("#cron_job_month").val(data.cron_job_month);
							$("#cron_job_dweek").val(data.cron_job_dweek);
							$("#cron_job_user").val(data.cron_job_user).prop('readonly', true).attr('tabindex', -1);
							$("#cron_job_command").val(data.cron_job_command);
							$("#cron_job_type").val(data.cron_job_type);
							$("#cron_job_id").val(data.cron_job_id);
							handleTimedateInputs($cronJobMinute.val());
							$dialog.dialog("open");
						});
						break;
					case "delete_cronjob":
						if (confirm("<?= self::escapeJs(tr('Are you sure you want to delete this cron job?', true));?>")) {
							doRequest(
								"POST", 'delete_cronjob', { cron_job_id: $(this).data('cron-job-id') }
							).done(function (data) {
								$dataTable.fnDraw();
								flashMessage('success', data.message);
							});
					}
					break;
				default:
					flashMessage('error', "<?= self::escapeJs(tr('Unknown action.', true));?>");
			}
		});

		$(document).
			ajaxStart(function () { $dataTable.fnProcessingIndicator(); }).
			ajaxStop(function () { $dataTable.fnProcessingIndicator(false); }).
			ajaxError(function (e, jqXHR, settings, exception) {
				if(jqXHR.status == 403) {
					window.location.replace("/index.php");
				} else if (jqXHR.responseJSON !== "undefined") {
					flashMessage("error", jqXHR.responseJSON.message);
				} else if (exception == "timeout") {
					flashMessage("error", "<?= self::escapeJs(tr('Request Timeout: The server took too long to send the data.', true));?>");
				} else {
					flashMessage("error", "<?= self::escapeJs(tr('An unexpected error occurred.', true));?>");
				}
			});
	});
</script>
