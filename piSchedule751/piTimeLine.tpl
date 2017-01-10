<!DOCTYPE html>
<html lang="de">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">


		<title>piSchedule `Timeline` </title>
		<!--  /cVersion/06-09-10_0/  -->

		<!-- optional: Einbinden der jQuery-Bibliothek -->
		<script src="https://code.jquery.com/jquery-1.11.2.min.js"></script>

		<!-- bootstrap downloaded and minified JS/CSS -->
		<link rel="stylesheet" href="static/bootstrap.min.css">
		<link rel="stylesheet" href="static/bootstrap-theme.min.css">
		<script src="static/bootstrap.min.js"></script>

		<script src="static/TL.timeline.js"></script>
		<script src="static/d3.min.js" charset="utf-8"></script>

		<link href="static/bootstrap-toggle.css" rel="stylesheet">
		<script src="static/bootstrap-toggle.js"></script>

		<script src="static/pi.docs.js"></script>
	</head>

	<body>

	<section class="container">

		<div class="jumbotron" 
			style="cursor:pointer; padding: 5px 0px; margin-bottom: 15px; margin-top: 10px;">
			<div class="container" id="goBack" title="Go back">
				<big><b><i> piSchedule </i> Timeline</b></big>
				<button class="btn btn-default btn-sm dropdown-toggle pull-right" type="button">
					<img title='help details' src='/static/ghome.png' width='14'>
				</button>
			</div>
		</div>

		<table border="0" cellpadding="2" cellspacing="2" width="100%">
			<tbody>
				<tr>

					<td valign="top" width="8%">
						<a class="btn btn-default btn-sm" 
							onclick="timeScale('left')"  title="Move to left"  role="button"> 
							<img src="/static/xLeft.png" width="18">
						</a>
					</td>

					<td align="center" valign="top">
						<div class="pull-right" >
							<a class="btn btn-default btn-sm "
								onclick="timeScale('++')"  title="Zoom In"  role="button"> 
								<img src="/static/xExpand.png" width="18">
							</a>

							<div class="btn-group">
								<button class="btn btn-default btn-sm dropdown-toggle" type="button"
									id="device" style="font-weight: bold"
									data-toggle="dropdown" aria-expanded="false">
									&&firstDevice&& &nbsp; &nbsp; &nbsp;<span class="caret"></span>
								</button>

								<ul class="dropdown-menu" role="menu">
									<li role="presentation">
										&&deviceList&&
									</li>
								</ul>
							</div>

							<input id="toggleDevice" data-toggle="toggle" data-size="small" 
								data-on="EIN" data-off="AUS" data-onstyle="warning"
								type="checkbox" >

							<a class="btn btn-default btn-sm"
								onclick="timeScale('--')"  title="Zoom Out"  role="button"> 
								<img src="/static/xCompress.png" width="18">
							</a>

							<a class="btn btn-default btn-sm" 
								onclick="reset(event)"  title="Reset"  role="button"> 
								<img src="/static/xReset.png" width="20">
						</a>

						</div>
					</td>

					<td valign="top" >
					<div class="pull-right">
						<a role="menuitem" title="Show details/status of 'Timeline' features" 
							style="cursor:pointer; padding-right:30px; padding-top:4px;"
							id="timelineDoc" ><img src="/static/ginfo.png" style="width:24px"></a>
						<a class="btn btn-default btn-sm" 
							id="legendSwitch"  title="Switch Legend for Jobs"  role="button"> {{legend}} </a>
&nbsp; &nbsp; &nbsp;
						<a class="btn btn-default btn-sm " 
							onclick="timeScale('right')" title="Move to Right"  role="button"> 
							<img src="/static/xRight.png" width="18">
						</a>

					</div>

					</td>

				</tr>
			</tbody>
		</table> 
		<br>

		<div id="timeline" onclick="cursorHandler(event)"></div>
		<p></p>

		<div class="jumbotron" style="padding:10px">
		<table cellpadding="2" cellspacing="2" width="100%" border="0">
			<tbody>
				<tr>
					<td valign="top">
						<div class="input-group pull-right">
							<span class="input-group-addon"><b>{{scheduleFile}}</b></span>
							<input style="width:250px" class="form-control" 
								id="fileName" placeholder="&&FILE&&" type="text">

							<a class="btn btn-default btn-sm" style="margin-left:20px" id="saveJobs" 
								title="*** Save current jobs setting to INI file." role="button"> 
								<img id="savebutton" src="/static/gsavegray.png" width="14">
							</a>
					</td>

					<td>
						<div class="pull-right">
							<a class="btn btn-default btn-sm" style="margin-left:20px" id="addNewJob" 
								title="*** Add a new job." role="button"> 
								<img id="addbutton" src="/static/gplus.png" width="14">
							</a>
						</div>
					</td>

				</tr>

			</tbody>
		</table>
		</div>


		<!-- modal Dialog for Day Schedule edit line, also add line -->
		<div id="editPlan" class="modal fade" tabindex="-1" role="dialog"
			aria-labelledby="editPlanLine" aria-hidden="true">
			<div class="modal-dialog">
				<div class="modal-content">

					<div class="modal-header">
						<span class="modal-title" id="workModalLabel"
						style="font-weight: bold">
							{{editJobs}} `&&firstDevice&&`
						</span>

						<div class="pull-right">
							<ul class="nav nav-pills pull-right">
								<li role="presentation">
									<a id="helpToggle" 
										style="cursor:pointer;padding-top: 4px;padding-bottom:5px;font-weight: bold">
										{{help}} ... </a>
								</li>

								<li role="presentation">
									<a style="cursor:pointer;padding-top: 5px;padding-bottom:5px;font-weight: bold" 
										data-dismiss="modal"> X </a>
								</li>
							</ul>
						</div>

					</div>

					<div class="modal-body" style="padding-bottum:0px!important">
						<div class="input-group pull-right" style="margin-left: 25px;">
							<span id="jobNoEdit" 
								class="input-group-addon"  style="font-weight: bold">
								Job
							</span>
							<input id="pickJob" 
								class="form-control" style="width:350px" type="text"
								value="preset text" jobno=""/>

							<a id="editJob" title="{{changeRow}}"
								class="btn btn-default btn-sm pull-right" role="button" 
								style="font-weight: bold">
								{{change}}
							</a>

						</div>

						<br>

						<p id="editDetailHelp" style="margin-left: 25px;margin-top:25px!important;display:none">
								{{timelineEditHelp}}
								<a role="menuitem" onclick="docs.open('Features')" style="cursor:pointer;">&nbsp;
									<i>piSchedule</i> Features &nbsp;
								</a>
						</p>
					</div>

					<div class="modal-footer" style="text-align:left">

						<a class="btn btn-default btn-sm pull-right" id="insertJob"
							title="{{insert}}" role="button" style="font-weight: bold">
							{{insert}}</a>

						<a class="btn btn-default btn-sm" id="deleteJob"
							title="{{delete}}" role="button" style="margin-left: 25px;font-weight: bold">
							{{delete}}</a>
					</div>

				</div><!-- /.modal-content -->
			</div><!-- /.modal-dialog -->
		</div><!-- /editPlan -->



	</section>

	<script language="javascript" type="text/javascript">
		var language = "{{locale}}";
		var docAddress = docs.DBox + language.toLowerCase() +'.'

		console.log(" *** piSchedule - piTimeLine : " + docAddress)

		var piScheduleValues= {}
		piScheduleValues.jobLines = "&&jobLines&&"

		piScheduleValues.setDevice = "&&firstDevice&&";
		piScheduleValues.firstDeviceStatus = "&&firstDeviceStatus&&"

		piScheduleValues.startTime = "&&startTime&&";
		piScheduleValues.endTime = "&&endTime&&";


		$("#addNewJob").click(function () {
			Timeline("#timeline")
			.work({addNewJob: '&&fileName&&'})
		});


		$("#saveJobs").click(function () {
			Timeline("#timeline")
			.saveJobs('&&fileName&&')
		});

		$("#insertJob").click(function () {
			var jobPicked = $('#pickJob')
			Timeline("#timeline")
			.work({insertJob: (jobPicked[0].attributes.jobno.value + "||" + jobPicked[0].value)})
		});

		$("#deleteJob").click(function () {
			var jobPicked = $('#pickJob')
			Timeline("#timeline")
			.work({deleteJob: (jobPicked[0].attributes.jobno.value )})
		});

		$("#editJob").click(function () {
			var jobPicked = $('#pickJob')
			Timeline("#timeline")
			.work({updateJob: (jobPicked[0].attributes.jobno.value + "||" + jobPicked[0].value)})
		});


		$('input#fileName').focus(function() {
			var input = $(this);

			if (input.val() == "") {
				input.val(input.attr('placeholder'));
				input.removeClass('placeholder');
				jobsChanged = true;
				$("#savebutton")[0].setAttribute("src","/static/gsaveblue.png")
			}
		});


		$("#timelineDoc").click(function () {
			window.open(docAddress + "timeline.html","docu");
		});


		function toggleOn() {
			$('#toggleDevice').bootstrapToggle('on')

		console.log("  loggle device   ON")
		}

		function toggleOff() {
			$('#toggleDevice').bootstrapToggle('off')  

			console.log("  loggle device   OFF")
		}

		$('#toggleDevice').change(function() {
			var currentDevice = stripAll($("#device")[0].textContent)
	//		console.log("   toggle on/off", $(this).prop('checked'), 
	//				" device: ", currentDevice);
			var state = $(this).prop('checked') ? 'on' : 'off'
			$.get('/onoff?'+ currentDevice + ','+ state);

				function stripAll (s){
						return (!s) ? "" : (s.replace(/\s+/g,"").replace("%20", ""))    // .replace(/\s+$/,"").replace(/^\s+/,""));
				};
		})


		$("#helpToggle").click(function () {
			$('#editDetailHelp').slideToggle(1000); 
			console.log("toggle editHelp");
			console.log("*****  testing access for docs: " + docs.Examples);

		});


		$('#goBack').on('click', function(event) {
			location.replace('/')
		});


		$('#legendSwitch').on('click', function(event) {
			Timeline("#timeline")
			.work({changeLegend: true})
		})


		// with page loading build ....
		$(document).ready(function() {
			var t = Timeline("#timeline")
			.sunrise("&&sunrise&&")
			.sunset("&&sunset&&")
			.startTime(piScheduleValues.startTime)
			.endTime(piScheduleValues.endTime)
			.startDate("2016-01-05")
			.endDate("2016-01-05")
			.xoptions({device:piScheduleValues.setDevice,
				xjobs:piScheduleValues.jobLines,
				log: true})
			// get state of first device and set the toggle switch
			$('#toggleDevice').bootstrapToggle(piScheduleValues.firstDeviceStatus)
		});


		function cursorHandler(xEvent){
			Timeline("#timeline")
			.cursorHandler(xEvent)
		}


		function timeScale(mode){
			Timeline("#timeline")
			.work({timeScale: mode})
		}


		function reset(cEvent) {
			Timeline("#timeline")
			.work({sunrise:"&&sunrise&&",
				sunset:"&&sunset&&",
				startTime: piScheduleValues.startTime,
				endTime: piScheduleValues.endTime,
				start:"2016-01-05",
				end:"2016-01-05",
				tooltext:"1",
				cEvent: cEvent,
				log:false })
		}

		/*
		*  called with pulldown menu when selecting another device
		*  menu is build with py /timeline
		*/
		function changeDevice(eThis) {
			piScheduleValues.setDevice = eThis.textContent
			location.replace('/timeline?'+piScheduleValues.setDevice)
		}


		$(window).on('beforeunload', function(e) {
			if (jobsChanged == true) {
				return '{ {unsavedStuff}}';
			}
		});
		
		</script>

	</body>
</html>
