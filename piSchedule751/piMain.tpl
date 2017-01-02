<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">

		<title>piSchedule (Main)</title>
		<!-- /cVersion/16-09-10_0/ -->

		<!-- optional: Einbinden der jQuery-Bibliothek -->
		<script src="https://code.jquery.com/jquery-1.11.2.min.js"></script>

		<!-- bootstrap downloaded and minified JS/CSS -->
		<link rel="stylesheet" href="static/bootstrap.min.css">
		<link rel="stylesheet" href="static/bootstrap-theme.min.css">
		<script src="static/bootstrap.min.js"></script>

		<script src="static/pi.docs.js"></script>


		<style type="text/css">
			h3 {
				background: silver;
			}

			h4 {
			  /* background: silver; */
			}

			.btn-input {
				display: block;
			}

			.btn-input .btn.form-control {
				text-align: left;
			}

			.btn-input .btn.form-control span:first-child {
				left: 10px;
				overflow: hidden;
				position: absolute;
				right: 25px;
			}

			.btn-input .btn.form-control .caret {
				margin-top: -1px;
				position: absolute;
				right: 10px;
				top: 50%;
			}

			table thead {
			  width: auto !important;
			}
		</style>

	</head>

	<body>

	<section class="container">

		<div class="jumbotron" 
			style="cursor:pointer; padding: 5px 0px; margin-bottom: 15px; margin-top: 10px;">
			<div class="container" id="main" title="{{mainMenuText}}">
				<big><b><i> piSchedule </i><small> -- {{mainMenu}}</small></b></big>
			</div>
		</div>

		<ul class="nav nav-pills">

			<li role="presentation" class="active"><a title="{{mainTitle}}" href="/schedule">{{mainText}}</a></li>

			<li role="presentation" class="dropdown">
				<a class="dropdown-toggle" data-toggle="dropdown"  role="button" aria-expanded="false" 
					href="#"  title="{{editTitle}}">&nbsp; {{jobLists}}<span class="caret"></span>
				</a>
				<ul id="editMenu" class="dropdown-menu" role="menu">
					&&iniFileList&&
				</ul>
			</li>

			<li role="presentation"><a title="Open pilight"  href={{pilight}}>
				<img src="/static/pilight.png" style="height:20px"></a>
			</li>

			<li role="presentation" class="dropdown">
				<a class="dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-expanded="false">
					{{help}} <span class="caret"></span>
				</a>
				<ul class="dropdown-menu" role="menu">
					<li role="presentation" >
						<a role="menuitem" style="cursor:pointer;" onclick="docs.open('Overview')">&nbsp; {{docOverview}} &nbsp;</a>
						<a role="menuitem" style="cursor:pointer;" onclick="docs.open('Edit')">&nbsp; {{docEdit}} &nbsp;</a>
						<a role="menuitem" style="cursor:pointer;" onclick="docs.open('timeline')">&nbsp; Timeline &nbsp;</a>
						<a role="menuitem" style="cursor:pointer;" onclick="docs.open('Examples')">&nbsp; {{docExamples}} &nbsp;</a>
						<a role="menuitem" style="cursor:pointer;" onclick="docs.open('Features')">&nbsp; {{docFeatures}} &nbsp;</a>
					</li>

					<li class='divider'></li>

					<li role='presentation'>
						 &&localeList&&
					 <!--	  <a role="menuitem"  style="cursor:pointer;" onclick="setLocale('DE')"  >&nbsp; Deutsch &nbsp;</a>
							<a role="menuitem"  style="cursor:pointer;" onclick="setLocale('EN')"  >&nbsp; English &nbsp;</a>
					 -->
					</li>

					<li class='divider'></li>
					<li role='presentation'>
						<a role="menuitem"  style="cursor:pointer;" onclick="piClose()"  >&nbsp; {{terminate}}</a>
					</li>

					<li class='divider'></li>
					<li role='presentation'>
						<a role="menuitem"  style="cursor:pointer;" onclick="piAbout()"  >&nbsp; {{about}}</a>
					</li>

				</ul>
			</li>

		</ul>


		<div id="weekDaySchedule" style="display:block"><br>

			<h4><b>{{weekdaySchedules}}</b>
				<a role="menuitem" title="Show details about 'Week Plan'"
					class='pull-right' style="cursor:pointer; padding-right: 30px; padding-top: 4px;" 
					id="weekPlan" onclick="docs.set(this)"><img src="/static/ginfo.png" style="width:24px">
				</a>
			</h4>

			<br>

			<div class="panel panel-default" >  <!-- Default panel contents -->

				<!-- Table -->
				 <table class="table">
					<thead>
						<tr>
							<th>{{weekday}}</th>
							<th>{{schedule}}</th>
							</tr>
					</thead>
					<tbody>
						<tr>
							<td>{{Monday}}</td>
							<td>
							<div class="input-group col-md-6 selectSchedule" data-placement="left" data-align="top" 
								data-autoclose="true" style="cursor:pointer" day="1">
								<input type="text" class="form-control" style="cursor:pointer" value="{{schedule1}}">
								<span class="input-group-addon">
								<img title='Edit' src='/static/gpencil.png' style='width:16px'>
								</span>
							</div>
							</td>
						</tr>
						<tr>
							<td>{{Tuesday}}</td>
							<td>
								<div class="input-group col-md-6 selectSchedule" data-placement="left" data-align="top" 
									data-autoclose="true" style="cursor:pointer" day="2">
									<input type="text" class="form-control" style="cursor:pointer" value="{{schedule2}}">
									<span class="input-group-addon">
										<img title='Edit' src='/static/gpencil.png' style='width:16px'>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<td>{{Wednesday}}</td>
							<td>
								<div class="input-group col-md-6 selectSchedule" data-placement="left" data-align="top" 
									data-autoclose="true" style="cursor:pointer" day="3">
									<input type="text" class="form-control" style="cursor:pointer" value="{{schedule3}}">
									<span class="input-group-addon">
										<img title='Edit' src='/static/gpencil.png' style='width:16px'>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<td>{{Thursday}}</td>
							<td>
								<div class="input-group col-md-6 selectSchedule" data-placement="left" data-align="top" 
									data-autoclose="true" style="cursor:pointer" day="4">
									<input type="text" class="form-control" style="cursor:pointer" value="{{schedule4}}">
									<span class="input-group-addon">
									<img title='Edit' src='/static/gpencil.png' style='width:16px'>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<td>{{Friday}}</td>
							<td>
								<div class="input-group col-md-6 selectSchedule" data-placement="left" data-align="top" 
									data-autoclose="true" style="cursor:pointer" day="5">
									<input type="text" class="form-control" style="cursor:pointer" value="{{schedule5}}">
									<span class="input-group-addon">
										<img title='Edit' src='/static/gpencil.png' style='width:16px'>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<td>{{Saturday}}</td>
							<td>
								<div class="input-group col-md-6 selectSchedule" data-placement="left" data-align="top" 
									data-autoclose="true" style="cursor:pointer" day="6">
									<input type="text" class="form-control" style="cursor:pointer" value="{{schedule6}}">
									<span class="input-group-addon">
										<img title='Edit' src='/static/gpencil.png' style='width:16px'>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<td>{{Sunday}}</td>
							<td>
								<div class="input-group col-md-6 selectSchedule" data-placement="left" data-align="top" 
									data-autoclose="true" style="cursor:pointer" day="7">
									<input type="text" class="form-control" style="cursor:pointer" value="{{schedule0}}">
									<span class="input-group-addon">
										<img title='Edit' src='/static/gpencil.png' style='width:16px'>
									</span>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</section>


	<!-- modal Dialog for WeekDay Schedule selection -->
	<div id="weekDayEdit" class="modal fade" tabindex="-1" role="dialog"
		aria-labelledby="weekPlan" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">

				<div class="modal-header">
					<span class="modal-title lead" id="modalHeader"
						style="font-weight: bold">
						{{selectTitle}}
					</span>

					<div class="pull-right">
						<ul class="nav nav-pills pull-right">
							<li role="presentation">
								<a id="helpToggle" 
									style="cursor:pointer;padding-top: 4px;padding-bottom:5px;font-weight: bold">
									{{help}} ... </a>
							</li>

							<li role="presentation">
								<a style="cursor:pointer;padding-top: 4px;padding-bottom:5px;font-weight: bold" 
									data-dismiss="modal"> X </a>
							</li>
						</ul>

					</div>

					<p id="weekScheduleHelp" style="margin-left: 25px;margin-top:25px!important;display:none">
						{{weekScheduleHelp}}
					</p>
				</div>

				<div class="modal-body" style="padding-bottum:0px!important">

					<div class="col-lg-6">
						<div class="input-group">
							<div class="input-group-btn">
								<button type="button" class="btn btn-default dropdown-toggle"
									data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
									{{select}}
									<span class="caret"></span>
								</button>

								<ul class="dropdown-menu" role="menu">
									<li role="presentation">
										&&iniFileList1&&
									</li>
								</ul>
							</div>
							<!-- /btn-group -->
							<input type="text" class="form-control" aria-label="..."
								id="weekdaySchedule" value="default.ini">
						</div><!-- /input-group -->
					</div><!-- /.col-lg-6 -->

				</div>

				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal"
						id="weekDayAction" title="Set the selected Schedule">
						{{set}}
					</button>

				</div>

			</div><!-- /.modal-content -->
		</div><!-- /.modal-dialog -->
	</div><!-- /weekSchedule -->


	<div id="helpModal" class="modal fade" tabindex="-1" role="dialog"
		aria-labelledby="helpLine" aria-hidden="true">
		<div class="modal-dialog modal-lg">
			<div class="modal-content">

				<div class="modal-header">
					<span class="modal-title lead" id="helpLabel">
						<i>piSchedule</i><b> Help</b> 
					</span>

					<div class="pull-right">
						<ul class="nav nav-pills pull-right">
							<li role="presentation">
								<a style="cursor:pointer;padding-top: 5px;padding-bottom:5px;font-weight: bold" 
									data-dismiss="modal"> X </a>
							</li>
						</ul>

						<a role="menuitem" 
							title="Open Help Doc on separate page." 
							style="cursor:pointer; padding-right: 10px; padding-top: 4px;" 
							id="goBook" onclick="docs.set(this)">
							<img src="/static/gbook.png">
						</a>
					</div>

				</div>
	
				<iframe id="frameHelp" src="" width="100%"
					onload="resizeIframe(this)" style="border: none"></iframe>

				<div class="modal-footer">
					<a role="menuitem" style="cursor: pointer;"
						id="doRepeat" onclick="docs.set(this)"> 
						<img src="/static/grepeat.png" style="width: 18px; margin-right: 18px">
					</a>
				</div>

			</div><!-- /.modal-content -->
		</div><!-- /.modal-dialog -->
	</div><!-- /helpModal -->



	<script language="javascript" type="text/javascript">
		var language = "{{locale}}";
		var docAddress = docs.DBox + docs.Schedule + language + "/"

	console.log(" *** piSchedule - piMain : " + docAddress)


		function resizeIframe(obj) {
			obj.style.height = window.innerHeight * .6 + "px";
		}


		// with page loading build ....
		$(document).ready(function() {
		});

		$('#home').on('click', function(event) {
			location.replace('/home')
		});


		$("#helpToggle").click(function () {
			$('#weekScheduleHelp').slideToggle(1000);
			console.log("toggle editHelp");
		});


		var currentDay
		var weekPosition

		$('.selectSchedule').on('click',
			function(event) {
				currentDay = event.currentTarget.attributes.day.value
				var value = $('.selectSchedule').find('input')[currentDay - 1].value
				weekPosition = $('.selectSchedule').find('input')[currentDay - 1]
				$('#weekDayEdit').modal('show');
			});


		$('#weekDayAction').click(function() {
			weekPosition.value = $("#weekdaySchedule")[0].value

			var allSchedules = ""
			for (var day = 0; day < 7; day++) {
				var sch = $('.selectSchedule').find('input')[day].value
				allSchedules += sch + ","
			}
			// update all day schedules to xS.prefs['weekSchedule'] (and prefs file)
			$.get('/updateWeekdaySchedule?' + allSchedules);
		})


		function piClose() {
			if (confirm("  *** piSchedule  beenden?") == true) {
				location.replace('/close')
				return
			}
		}

		function piAbout() {
			var browser = navigator.userAgent + " (" + navigator.language + ")";
			console.log("piSchedule About  browser: " + browser)

			location.replace('/about')
			return
		}

		function setLocale(lang) {
			language = lang
			console.log("piMain	set 'Locale'  language:" + language)
			$.get('/locale', lang)

			setTimeout(function() {
				location.replace('/home')
			}, 150);
		};
	</script>


	</body>

</html>
