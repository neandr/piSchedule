<!DOCTYPE html>
<html lang="de">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">

		<title>piSchedule Edit</title>
		<!-- /cVersion/16-09-10/ -->

		<!-- optional: Einbinden der jQuery-Bibliothek -->
		<script src="https://code.jquery.com/jquery-1.11.2.min.js"></script>

		<!-- bootstrap downloaded and minified JS/CSS -->
		<link rel="stylesheet" href="static/bootstrap.min.css">
		<link rel="stylesheet" href="static/bootstrap-theme.min.css">
		<script src="static/bootstrap.min.js"></script>

		<!--  support time picking with bootstrap lib  -->
		<link rel="stylesheet" type="text/css" href="/static/bootstrap-clockpicker.css">
		<script src="/static/bootstrap-clockpicker.js"></script>

		<script src="static/pi.docs.js"></script>

	<style type="text/css">
		h3 {background: silver;
		}
	</style>

	<script>
		$.valHooks.textarea = {
			get : function(elem) {
				return elem.value.replace(/\n/g, "|").replace(/#/g, "%23");
			}
		};

	</script>

	</head>

	<body>
	<section class="container">

		<div class="jumbotron" 
			style="cursor:pointer; padding: 5px 0px; margin-bottom: 15px; margin-top: 10px;">
			<div class="container" id="main" title="{{gotoMain}}">
				<big><b><i> piSchedule </i><small> -- {{prefJobs}}</small></b></big>
				<button class="btn btn-default btn-sm dropdown-toggle pull-right" type="button">
					<img title='Help details' src='/static/ghome.png' width='14'>
				</button>
			</div>
		</div>

		<table class="table table-striped table-bordered">
			<tbody>
				<tr>
					<td><b>{{location}}</b></td>
					<td></td>
					<td align="right"><b>&&datetime&&</b></td>
				</tr>
				<tr>
					<td><b>Latitude </b> {{latitude}}</td>
					<td><b>{{Sunrise}} </b> {{sunrise[10:16]}}</td>
					<td align="right"><small>Version {{version}} ({{locale}} / {{geo}})</small></td>
				</tr>
				<tr>
					<td><b>Longitude </b> {{longitude}}</td>
					<td><b>{{Sunset}} </b> {{sunset[10:16]}}</td>
					<td align="right"><small></small></td>
				</tr>
			</tbody>
		</table>


		<span id="jobDefTitleEdit" style="&&jobDefEdit&&">
			<h4><b>{{jobDef}}</b>
				<a id='jobDefinition' onclick="docs.set(this, 'Edit')" 
					style="cursor:pointer"><small><i>{{editJob}}</i></small>
					<img title="" src="/static/ginfo.png" style="width:24px; margin-left:18px;">
				</a>
				<ul class="nav nav-pills pull-right">
					<li role="presentation"><a style="cursor:pointer" onclick="jobAction(this,'add')">&nbsp; {{add}} &nbsp;</a></li>
					<li role="presentation"><a style="cursor:pointer" onclick="jobAction(this,'clear')">&nbsp; {{reset}} &nbsp;</a></li>
				</ul>
			</h4>
		</span>


		<span id="jobDefTitleExec" style="&&jobDefExec&&">
			<h4><b>{{jobDef}}</b>

				<a id='jobDefinition' onclick="docs.set(this, 'Edit')" style="cursor:pointer"><small><i>{{createJob}}</i></small>
					<img title="" src="/static/ginfo.png" style="width:24px; margin-left:18px;">
				</a>

				<ul class="nav nav-pills pull-right">
					<li role="presentation"><a style="cursor:pointer" onclick="controlGET()">&nbsp; {{exJob}} &nbsp;</a></li>
					<li role="presentation"><a style="cursor:pointer" onclick="jobAction(this,'clear')">&nbsp; {{reset}} &nbsp;</a></li>
					<li role="presentation"><a href='/refresh'>&nbsp; &lt;&lt; &nbsp;&nbsp;{{back}}</a></li>
				</ul>
			</h4>
		</span>


		<!-- edit /create / delete Job definitions  etc  -->
		<div class="jumbotron" style="padding:10px">
			<div class="btn-group">
				<button class="btn btn-default btn-sm dropdown-toggle" type="button"
						id="device" noItem
						data-toggle="dropdown" aria-expanded="false">
						{{Device}} &nbsp; -- &nbsp;&nbsp;&nbsp;<span class="caret"></span>
				</button>
				<ul class="dropdown-menu" role="menu">
					<li role="presentation">
						<a role="menuitem" noItem onclick="changeDevice(this)">{{Device}}&nbsp; -- &nbsp;</a>
						&&deviceList&&
					</li>
				</ul>
			</div>	<!-- device -->

			<div class="btn-group">  <!-- ON -->
				<button class="btn btn-default btn-sm dropdown-toggle clockpicker-with-callbacks" type="button"
						id="ON"
						data-toggle="dropdown" aria-expanded="false">
						{{ON}} &nbsp; -- &nbsp;&nbsp;&nbsp;<span class="caret"></span>
				</button>
				<ul class="dropdown-menu" role="menu">
					<li role="presentation" menuType="ON">

						<a role="menuitem" noItem	typ=""			onclick="changeTime(this)">&nbsp; -- &nbsp;</a>
						<a role="menuitem" tControl typ="time"	  onclick="changeTime(this)">{{Time}}</a>
						<a role="menuitem" sun		typ="sunrise"  onclick="changeTime(this)">{{Sunrise}}</a>
						<a role="menuitem" sun		typ="sunset"	onclick="changeTime(this)">{{Sunset}}</a>
					</li>
				</ul>
			</div>	<!-- ON -->

			<div class="btn-group">	<!-- ONoffset -->
				<button class="btn btn-default btn-sm dropdown-toggle clockpicker-with-callbacks" type="button"
						id="ONoffset"
						data-toggle="dropdown" aria-expanded="false">
						{{ONoffset}} &nbsp; -- &nbsp;&nbsp;&nbsp;<span class="caret"></span>
				</button>
				<ul class="dropdown-menu" role="menu">
						<li role="presentation" menuType= 'ONoffset'>
							<a role="menuitem" noItem	typ=""			onclick="changeTime(this)">&nbsp; -- &nbsp;</a>
							<a role="menuitem" tControl typ="time+"	 onclick="changeTime(this)">+</a>
							<a role="menuitem" tControl typ="time-"	 onclick="changeTime(this)">-</a>
							<a role="menuitem" tControl typ="random"	onclick="changeTime(this)">{{random}}</a>
							<a role="menuitem" tControl typ="random-"  onclick="changeTime(this)">{{randomMinus}}</a>
						</li>
				</ul>
			</div>	<!-- ONoffset -->

			<div class="btn-group">	<!-- OFF -->
				<button class="btn btn-default btn-sm dropdown-toggle clockpicker-with-callbacks" type="button"
						id="OFF"
						data-toggle="dropdown" aria-expanded="false">
						{{OFF}} &nbsp; -- &nbsp;&nbsp;&nbsp;<span class="caret"></span>
				</button>
				<ul class="dropdown-menu" role="menu">
					<li role="presentation" menuType="OFF">

						<a role="menuitem" noItem	typ=""			onclick="changeTime(this)">&nbsp; -- &nbsp;</a>
						<a role="menuitem" tControl typ="time+"	 onclick="changeTime(this)">+</a>
						<a role="menuitem" tControl typ="time"	  onclick="changeTime(this)">{{Time}}</a>
						<a role="menuitem" sun		typ="sunrise"  onclick="changeTime(this)">{{Sunrise}}</a>
						<a role="menuitem" sun		typ="sunset"	onclick="changeTime(this)">{{Sunset}}</a>

					</li>
				</ul>
			</div>	<!-- OFF -->

			<div class="btn-group">	<!-- OFFoffset -->
				<button class="btn btn-default btn-sm dropdown-toggle clockpicker-with-callbacks" type="button"
						id="OFFoffset"
						data-toggle="dropdown" aria-expanded="false">
						{{OFFoffset}} &nbsp; -- &nbsp;&nbsp;&nbsp;<span class="caret"></span>
				</button>
				<ul class="dropdown-menu" role="menu">
					<li role="presentation" menuType="OFFoffset">
						<a role="menuitem" noItem	typ=""			onclick="changeTime(this)">&nbsp; -- &nbsp;</a>
						<a role="menuitem" tControl typ="time+"	 onclick="changeTime(this)">+</a>
						<a role="menuitem" tControl typ="time-"	 onclick="changeTime(this)">-</a>
						<a role="menuitem" tControl typ="random"	onclick="changeTime(this)">{{random}}</a>
						<a role="menuitem" tControl typ="random-"  onclick="changeTime(this)">{{randomMinus}}</a>
					</li>
				</ul>
			</div>  <!-- OFFoffset -->


			<!--  row with jobNo and current Job text -->
			<div style="margin-left:20px;margin-top:5px" id="jobDetail" class="clockpicker-with-callbacks">
				<textbox id="jobNo" class="col-md-1">#</textbox></span>
				<i><textbox id="currentJob">---</textbox></i>
				<small><textbox class="pull-right" id="controlStatus">-s-</textbox></i></small>
			</div>

		</div>	<!-- edit /create / delete Job definitions  etc  -->

		<div id="daySchedule" style="&&displaySchedule&&">

<!-- ......	Collection and Storage of Job Definitions	..... -->
			<h4><b>{{jobList}}</b>
				<a id='Edit' onclick="docs.open(this.id)" style="cursor:pointer"><small><i>{{editJobList}}</i>
					<img title="" src="/static/ginfo.png" style="width:24px; margin-left:18px;">
				</a>
			</h4>

			<div class="jumbotron" style="padding:10px">
				<div class="input-group pull-right" >
					<span class="input-group-addon"><b>{{scheduleFile}}</b></span>

					<input class="form-control" id="fileName" placeholder="&&FILE&&" style="width:350px" 
						type="text"/>

					<a class="btn btn-default btn-sm  disabled="true" id="saveDaySchedule"	
						 onclick="saveIt()" title="{{saveJobList}}"  role="button">{{save}}</a>

					<a class="btn btn-default btn-sm	id="deleteDaySchedule"
						 onclick="deleteIt()" title="{{deleteJobList}}"  role="button">{{delete}}</a>

				</div>

				<div>
					<span>&nbsp;&nbsp;&nbsp;</span><span id="jobListChanged">--</span>

					<div class="btn-group pull-right">

						<button
							class="btn btn-default btn-sm dropdown-toggle pull-right "
							type="button" id="jobAction" title="{{editJobandList}}"
							data-toggle="dropdown" aria-expanded="false">
							<img title='&&title' src='/static/gpencil.png' style='width:18px'>
							<span class="caret"></span>
						</button>


						<ul class="dropdown-menu pull-right " role="menu">
							<a role="menuitem">&nbsp; {{selectedJob}} ... </a>
							<li role="presentation">
								<a role="menuitem" style="cursor: pointer" id="jobEdit" onclick="jobAction(this,'edit')">&nbsp; {{edit}} &nbsp;</a>
								<a role="menuitem" style="cursor: pointer" id="jobDelete" onclick="jobAction(this,'delete')">&nbsp; {{erase}} &nbsp;</a>
								<a role="menuitem" style="cursor: pointer" id="jobUp" onclick="jobAction(this,'up')">&nbsp; {{shiftUp}} &nbsp;</a>
								<a role="menuitem" style="cursor: pointer" id="jobDown" onclick="jobAction(this,'down')">&nbsp; {{shiftDown}} &nbsp;</a>
								<br>
								<a role="menuitem" style="cursor: pointer" id="editRow" onclick="jobAction(this,'editRow')">&nbsp; {{advanceEditRow}}</a>
							 </li>	  
						 </ul>
					</div>
				</div>

				<!--	List of ini entries -->
				<select id="jobsList" class="form-control" size="10">
					  &&JOBS&&
				</select>
			</div> <!-- jumbotron-->
		</div>  <!-- daySchedule -->

		<!-- modal Dialog for Day Schedule edit line -->
		<div id="editPlan" class="modal fade" tabindex="-1" role="dialog"
			aria-labelledby="editPlanLine" aria-hidden="true">
			<div class="modal-dialog">
				<div class="modal-content">

					<div class="modal-header">
						<span class="modal-title lead" id="workModalLabel"
						style="font-weight: bold">
							{{editJobRow}}
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

					</div>

					<div class="modal-body" style="padding-bottum:0px!important">
						<div class="input-group pull-right" style="margin-left: 25px;">
							<span class="input-group-addon">
								<b>Job</b>
							</span>
							<input class="form-control" id="rowJob" style="width:350px"
								value="preset text" type="text" />

							<a class="btn btn-default btn-sm pull-right" id="changeRow"
								onclick="jobAction(this, 'addAdvance')" title="{{changeRow}}" 
								style="font-weight: bold" role="button">
								{{edit}}</a>
						</div>

						<br>

						<p id="editDetailHelp" style="margin-left: 25px;margin-top:25px!important;display:none">
								{{advanceEditHelp}}
								<a role="menuitem" onclick="docs.open('Features')" style="cursor:pointer;">&nbsp;
									<i>piSchedule</i> Features &nbsp;
								</a>
						</p>
					</div>

					<div class="modal-footer">

						<a class="btn btn-default btn-sm pull-right" id="insertRow"
							onclick="jobAction(this, 'addAdvance')" title="{{insertRow}}"
							style="font-weight: bold" role="button">
							{{insert}}</a>
					</div>

				</div><!-- /.modal-content -->
			</div><!-- /.modal-dialog -->
		</div><!-- /editPlan -->


		<!-- modal Dialog for piHelp  -->
		<div id="helpModal" class="modal fade" tabindex="-1" role="dialog" 
			aria-labelledby="helpLine" aria-hidden="true">
			<div class="modal-dialog modal-lg">
				<div class="modal-content">

					<div class="modal-header">
						<span class="modal-title lead" id="helpLabel"
						style="font-weight: bold">
							<i>piSchedule</i>
							<b> Help</b> 
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

					<iframe id="frameHelp" src="" width="100%" onload="resizeIframe(this)"
						style="border:none"></iframe>

					<div class="modal-footer">
						<a role="menuitem" style="cursor:pointer;"
							id="doRepeat" onclick="docs.set(this)">
							<img src="/static/grepeat.png" style="margin-right:18px">
						</a>
					</div>

				</div><!-- /.modal-content -->
			</div><!-- /.modal-dialog -->
		</div><!-- /helpModal -->

	</section> <!-- container  -->


	<script language="javascript" type="text/javascript">
		var language = "{{locale}}";
		var docAddress = docs.DBox + language.toLowerCase() +'.'

	console.log(" *** piSchedule - piEdit : " + docAddress)


		function resizeIframe(obj) {
			obj.style.height = window.innerHeight * .6 + "px";
		}


		$("#helpToggle").click(function () {
			$('#editDetailHelp').slideToggle(1000); 
			console.log("toggle editHelp");
		});


		function controlGET() {
			$.get('/control', $('#currentJob').text(), function(data, status) {
				$('#controlStatus').html(status);
			 });
		};


		function clearButton(name, title) {
			var button = $('#' + name);
			button.removeAttr('value');
			button.html(title
				 + ' &nbsp; -- &nbsp;&nbsp;&nbsp;<span class="caret"></span>');
		}


		function checkButton(button) {
			return !($('#' + button)[0].attributes.value == null);
		}


		/**
		 *  write a 'job' line to Job Definition  and parse it for buttons
		 **/
		function jobSetup(job, jobNo) {
			jobAction(null, 'clear');

			$('#currentJob').html(job);
			$('#jobNo').html('#' + jobNo);

			//parse job to get: device;on,onOffset;off,offOffset
			var sArray = job.split(";");

			if (sArray.length > 0) {
				// first item can't be 'on' or 'off'
				if ((sArray[0].substring(0, 2).toLowerCase() == 'on')
						|| (sArray[0].substring(0, 3).toLowerCase() == 'off')) {
					alert('{{errJob}}!\n' + sArray[0]);
					return;
				}

				setDevice = sArray[0].trim();
				// iterate over control strings sep by  ; starting without 'device'
				for (var i = 1; i < sArray.length; i++) {
					var cItem = sArray[i].trim();
					var aItems = cItem.split(",");

					var onOff = aItems[0].trim();

					if (onOff == 'on') {
						for (var j = 1; j < aItems.length; j++) {
							var arg = aItems[j].trim();

							if ((arg == 'sunrise') || (arg == 'sunset')) {
								modeON = arg;
								setON = arg;
							}
							if (arg.substring(0, 2) == '~-') {
								modeONoffset = '~-';
								setONoffset = arg.substring(2).trim();
							} else if ((arg[0] == '+') || (arg[0] == '-')
									|| (arg[0] == '~')) {
								modeONoffset = arg[0];
								setONoffset = arg.substring(1).trim();
							} else {
								setON = arg.trim();
								modeON = "";
							}
							if (setON[0] == ":")
								setON = "00" + setON;
							if (setONoffset[0] == ":")
								setONoffset = "00" + setONoffset;
						}
					}

					else if (onOff == 'off') {
						for (var j = 1; j < aItems.length; j++) {
							var arg = aItems[j].trim();

							if ((arg == 'sunrise') || (arg == 'sunset')) {
								modeOFF = arg;
								setOFF = arg;
							} else if (arg.substring(0, 2) == '~-') {
								modeOFFoffset = '~-';
								setOFFoffset = arg.substring(2).trim();
							} else if ((arg[0] == '-') || (arg[0] == '~')) {
								modeOFFoffset = arg[0];
								setOFFoffset = arg.substring(1).trim();
								offOffset = arg;
							} else if ((arg[0] == '+') && (setOFF == '')) {
								modeOFF = '+';
								setOFF = arg.substring(1).trim();
							} else if ((arg[0] == '+') && (setOFF != '')) {
								modeOFFoffset = '+';
								setOFFoffset = arg.substring(1).trim();
							} else {
								modeOFF = '';
								setOFF = arg.trim();
							}
							if (setOFF[0] == ":")
								setOFF = "00" + setOFF;
							if (setOFFoffset[0] == ":")
								setOFFoffset = "00" + setOFFoffset;
						}
					}

					else {
						alert("Instruction >>" + onOff + "<< unknown!");
					}

				} // for time values
			} // for control string

// console.log("ON	" + setON  + "  mode >>"+ modeON  +"<<  ONoffset:  " + setONoffset  + "	mode >>"+ modeONoffset + "<<")
// console.log("OFF  " + setOFF + "  mode >>"+ modeOFF +"<<  OFFoffset: " + setOFFoffset + "	mode >>"+ modeOFFoffset + "<<")

			//set the buttons
			var b = bold(setDevice)
			$('#device').html(b[0] + setDevice + ' &nbsp;&nbsp;<span class="caret"></span>' + b[1]);
			$('#device').attr('value', setDevice);

			var b = bold(setON);
			$('#ON').html(b[0] + '{{ON}} ' + ' &nbsp;' + setON + '&nbsp;<span class="caret"></span>' + b[1]);
			$('#ON').attr('value', setON);

			var b = bold(setONoffset);
			$('#ONoffset').html(b[0] + '{{ONoffset}} ' + modeONoffset + ' &nbsp;' + setONoffset + '&nbsp;<span class="caret"></span>' + b[1]);
			$('#ONoffset').attr('value', setOFFoffset);

			var b = bold(setOFF);
			$('#OFF').html(b[0] + '{{OFF}} ' + modeOFF + ' &nbsp;' + setOFF + '&nbsp;<span class="caret"></span>' + b[1]);
			$('#OFF').attr('value', setOFF);

			var b = bold(setOFFoffset);
			$('#OFFoffset').html(b[0] + '{{OFFoffset}} ' + modeOFFoffset + ' &nbsp;' + setOFFoffset + '&nbsp;<span class="caret"></span>' + b[1]);
			$('#OFFoffset').attr('value', setOFFoffset);

			function bold(s) {
				var b = [];
				b[0] = '<b>';  b[1] = '</b>';
				if (s == "") {
					b[0] = '';  b[1] = '';
				}
				return b;
			}
		}


		/**
		 *  get the button settings and build the 'job'
		 *  @param  setJob:  if passed write to text line 
		 **/
		function buildJob(setJob) {
			var _ONoffset = "", _OFFoffset = ""

			var _ON = (setON != "") ? ";on," + setON : ""
			if (_ON != "")
				_ONoffset = (setONoffset != "") ? "," + modeONoffset + setONoffset : "";

			var _OFF = ""
			if ((setOFF == "--") || (setOFF == "")){
				 _OFFoffset = (setOFFoffset != "") ? ";off, " + modeOFFoffset + setOFFoffset : "";

			} else {
				_OFF = (setOFF != "") ? ";off," + modeOFF + setOFF : "";
				if (_OFF != "")
				  _OFFoffset = (setOFFoffset != "") ? "," + modeOFFoffset + setOFFoffset : "";
			}

			var job = setDevice + _ON + _ONoffset + _OFF + _OFFoffset;
			if (setJob != null) {
				$('#currentJob').html(job);
				$('#controlStatus').html(' -- ');
			}
			return job
		}


		/**
		 *	 actions for 'Job' on Job Definition section
		 *	@param  {object} eThis 
		 *			  {string} info: controls action,
		 *				  'build'  build job from buttons
		 *				  'read'	read from Job List active line
		 *				  'add'	 add the current job before active line
		 *				  'delete' delete active entry from Job List
		 **/
		function jobAction(eThis, info) {

			var msg = "";

			if (info == 'editRow') {

				// check Day Schedule if a 'job' is selected
				var jobsList = $('#jobsList');
				var jobNo = jobsList[0].selectedIndex;

				var cText = "";
				if (jobNo != -1){
				  cText = jobsList[0].selectedOptions[0].text;
				}
		//		console.log ("job	No:"+ jobNo + "  text:" + cText)
				document.getElementById("rowJob").value =  cText;
				$('#editPlan').modal('show');
				return
			}


			if (info == 'clear') {
				clearButton('device', '{{Device}}');
				clearButton('ON', '{{ON}}');
				clearButton('ONoffset', '{{ONoffset}}');
				clearButton('OFF', '{{OFF}}');
				clearButton('OFFoffset', '{{OFFoffset}}');

				$('#currentJob').html(' --- ');
				$('#controlStatus').html(' -- ');
				$('#jobNo').html('#');
				//$('#setTime').attr('style', 'display:none');

				setON = "";
				setONoffset = "";
				setOFF = "";
				setOFFoffset = "";
				modeON = "";
				modeONoffset = "";
				modeOFF = "";
				modeOFFoffset = "";

				return
			}

			if (info == 'build') {
				var check = $('#device');
				var device = check[0].textContent.trim();
				if (!!check[0].attributes.noItem) {
					alert("{{deviceNotSelected}}");
					return;

				}
				var rv = buildJob();
				//		 alert ("[jobAction]  " + info + "  >>" + rv + '<<');
				return;
			}

			// check Day Schedule if a 'job' is selected
			var jobsList = $('#jobsList');
			var jobNo = jobsList[0].selectedIndex;


			// add the 'Job' on job definition line to the jobsList
			if (info == 'addAdvance') {
				var cJob =  $('#rowJob')[0].value;

				// insert in 'Day Schedule' before activated line
				var option = document.createElement("option");
				option.text = cJob;
				document.getElementById("jobsList").add(option, jobNo);

				if(eThis.id == "changeRow") {
					jobsList[0][jobNo+1].remove();
					jobsList[0].selectedIndex = jobNo+1;
				}

				// jobList has changed !  ==> set "changed"
				$("#jobListChanged")[0].textContent = "(changed)";
				changed = true;

			} else 

			// add the 'Job' on job definition line to the jobsList
			if (info == 'add') {
				var cJob = $('#currentJob')[0].textContent;

				//  if no Device selected, terminate
				if (checkButton('device') == false) {
					alert(" {{deviceNotDefined}}");
					return;
				}

				if ((setON == "") && ((setOFF == ""))) {
					alert(" {{defineTime}}")
					return
				}

				// insert in 'Day Schedule' before activated line
				var option = document.createElement("option");
				option.text = cJob;
				document.getElementById("jobsList").add(option, jobNo);

				// jobList has changed !  ==> set "changed"
				$("#jobListChanged")[0].textContent = "(changed)";
				changed = true;
			}

			else {
				if (jobNo != -1){
					  cText = jobsList[0].selectedOptions[0].text;
					}
				var job = jobsList[0].selectedOptions[0].text;

				// read activated job on Day Schedule and place it to Job Definition
				if (info == 'edit') {
					//		 alert ("[jobAction]  " + info + "  >>" + job + '<<')

					jobSetup(job, jobNo);
					return;
				}

				if (info == 'delete') {
					//TODO	ask user if OK to delete !
					var a = jobsList;
					jobsList[0][jobNo].remove();

					jobsList[0].selectedIndex = jobNo;
	
					// jobList has changed !  ==> set "changed"
					$("#jobListChanged")[0].textContent = "(changed)";
					changed = true;
				}

				//shift activate 'job' on jobsList
				if (info == 'up') {
					if (jobNo == 0)
						return;

					var a = jobsList[0][jobNo];
					jobsList[0][jobNo].remove();
					document.getElementById("jobsList").add(a, jobNo - 1);

					// jobList has changed !  ==> set "changed"
					changed = true;
				}

				//shift activate 'job' on jobsList
				if (info == 'down') {
					if (jobNo == jobsList.length - 1)
						return;

					var a = jobsList[0][jobNo];
					jobsList[0][jobNo].remove();
					document.getElementById("jobsList").add(a, jobNo + 1);

					// jobList has changed !  ==> set "changed"
					changed = true;
				}

			}
		}

		$('#main').on('click', function(event) {
			if (changed == true) {
				msg = "{{unsavedStuff}}";
				var x =  confirm(msg);
				console.log("unsaved test" + x);
				if (x  == true) {
					 saveIt(true);
				}
			}
			location.replace('/home');
			return;
		});


		/**
			Global parameters
		 **/
		var changed = false;

		var menuType, timeType, timeTypeLocal, timeValue;

		//default time values
		var ONhh = '11';
		var ONmin = '00';

		var OFFhh = '12';
		var OFFmin = '00';

		var OFFSEThh = '00';
		var OFFSETmin = '25';

		var setDevice = "", setON = "", setONoffset = "", setOFF = "", setOFFoffset = "";
		var modeDevice, modeON, modeONoffset, modeOFF, modeOFFset;


		function two(num) {
			if (+(num) < 10)
				num = '0' + +(num);
			return num;
		}

		function changeDevice(eThis) {
			setDevice = eThis.textContent;
			//  alert(" .... change Device ... :" + device);
			$('#device').html('<b>'+ setDevice
				  + '&nbsp;&nbsp;&nbsp;</b><span class="caret"></span>');
			if (eThis.getAttribute('noitem') == "") {
				$('#device').removeAttr('value');
			} else {
				$('#device').attr('value', setDevice);
			}
			buildJob(true);
		}


		function changeTime(eThis) {
			var mode = '', deco = '<i>', deco1 = '</i>';

			timeTypeLocal = eThis.textContent; // {{Sunset}}  or {{Time}}
			timeType = 'time';

			_menuType = eThis.parentElement.getAttribute('menuType')
			if (_menuType != null)
				menuType = _menuType; // 'ON'  or  'ONoffset'

			_timeType = eThis.getAttribute('typ');
			if (_timeType != null)
				timeType = eThis.getAttribute('typ'); // 'time'  or  'sunset' or '' for noItem


			if (timeType == "time+")
				mode = "+";
			if (timeType == "time-")
				mode = "-";
			if (timeType == "random")
				mode = "~";
			if (timeType == "random-")
				mode = "~-";
			if (timeType == "")
				mode = "x";

			if (menuType == 'ON') {

				modeON = mode;
				if (mode == "x"){
					 timeValue = "--";
					 setON = "";
					 setONoffset = "";
				} else
				if ((timeType == 'sunrise') || (timeType == 'sunset')) {
					setON = timeType;
					timeValue = timeTypeLocal;
					var deco = '<b>';
					var deco1 = '</b>';
				} else {

					var tDetails = $('#' + menuType)[0].textContent
							.match(/\d+/g);
					if (tDetails == null) {
						var t = new Date();
						// inkrement ... min
						var t2 = t.getTime();
						var dt = t2 + (1 * 60000);
						t.setTime(dt);

						ONhh = two(t.getHours());
						ONmin = two(t.getMinutes());
					} else {
						ONhh = two(tDetails[0]);
						ONmin = two(tDetails[1]);
					}
					setON = ONhh + ":" + ONmin;
					timeValue = modeON + " " + setON;

					$('#ON').clockpicker()
						.clockpicker('show',{
						'current': setON
					});
				}

		//		console.log("ON	  setON:" + setON + "	modeON >>" + modeON + "<<")
				setButton ('ON', '{{ON}}', deco, deco1, timeValue);
				if (timeValue == "--")
					setButton ('ONoffset', '{{ONoffset}}', deco, deco1, timeValue);
			}

			if (menuType == 'ONoffset') {
				modeONoffset = mode;

				if (mode == "x") {
					timeValue = " -- ";
					setONoffset = "";
				} else {
					var tDetails = $('#' + menuType)[0].textContent.match(/\d+/g);
					if (tDetails == null) {
						ONSEThh = '00';
						ONSETmin = '30';
					} else {
						ONSEThh = two(tDetails[0]);
						ONSETmin = two(tDetails[1]);
					}
					setONoffset = ONSEThh + ":" + ONSETmin;
					timeValue = modeONoffset + "  " + setONoffset;

					$('#ONoffset').clockpicker()
						.clockpicker('show',{
						'current': setONoffset
					});
				}
		//		console.log("ON	setONoffset:" + setONoffset + "	modeON >>" + modeONoffset + "<<");
				setButton ('ONoffset', '{{ONoffset}}', deco, deco1, timeValue);
			}


			if (menuType == 'OFF') {

				modeOFF = mode
				if (mode == "x"){
					timeValue = "--";
					setOFF = "";
					setOFFoffset = "";
				} else
				if ((timeType == 'sunrise') || (timeType == 'sunset')) {
					setOFF = timeType;
					timeValue = timeTypeLocal;
					var deco = '<b>';
					var deco1 = '</b>';
				} else {

					var tDetails = $('#' + menuType)[0].textContent.match(/\d+/g);
					if (tDetails == null) {
						var t = new Date();
						OFFhh = two(t.getHours());
						OFFmin = two(t.getMinutes());
					} else {
						OFFhh = two(tDetails[0]);
						OFFmin = two(tDetails[1]);
					}
					setOFF = OFFhh + ":" + OFFmin;
					timeValue = modeOFF + setOFF;
					var deco = '<i>';
					var deco1 = '</i>';

					$('#OFF').clockpicker()
						.clockpicker('show',{
						'current': setOFF
					});
				}
		//		console.log("OFF	setOFF:" + setOFF + "	modeOFF >>" + modeOFF + "<<")
				setButton ('OFF', '{{OFF}}', deco, deco1, timeValue);
				if (timeValue == "--")
					setButton ('OFFoffset', '{{OFFoffset}}', deco, deco1, timeValue);
			}


			if (menuType == 'OFFoffset') {
				modeOFFoffset = mode

				if (mode == "x") {
					timeValue = " -- ";
					setOFFoffset = "";
				} else {
					var tDetails = $('#' + menuType)[0].textContent.match(/\d+/g);
					if (tDetails == null) {
						OFFSEThh = '00';
						OFFSETMIN = '30';
					} else {
						OFFSEThh = tDetails[0];
						OFFSETmin = tDetails[1];
					}
					setOFFoffset = OFFSEThh + ":" + OFFSETmin;
					timeValue = modeOFFoffset + setOFFoffset;

					$('#OFFoffset').clockpicker()
						.clockpicker('show',{
						'current': setOFFoffset
					});
				}
		//		console.log("OFF	setOFFoffset:" + setOFFoffset + "	modeOFFoffset >>" + modeOFFoffset + "<<");
				setButton ('OFFoffset', '{{OFFoffset}}', deco, deco1, timeValue);
			}

			buildJob(true);
		}


		function setButton (modus, label, deco, deco1, timeValue){
			 $('#' + modus).html(deco + label + '&nbsp;&nbsp;' + timeValue
						+ '&nbsp;&nbsp;&nbsp;' + deco1
						+ '<span class="caret"></span>');
		}


		/**
		 *  ini File functions
		 **/
		function deleteIt() {
			change = false;
			var fN = $('input#fileName').val();
			var fP = $('input#fileName').attr('placeholder');

			if (confirm("Delete the Day Schedule file " + fP + "?") == true) {
				$.get('/fDelete?[{"fName":"' + fN + '"},{"pName":"' + fP + '"}]');
				setTimeout(function() {
					location.replace('/home')
				}, 100)
			}
		};


		function saveIt(force) {
			var fN = $('input#fileName').val();
			var fP = $('input#fileName').attr('placeholder');
			var jobs = getJobs();

			$("#jobListChanged")[0].textContent = "";

			$.get('/fSave?[{"fName":"' + fN + '"},{"pName":"' + fP
					+ '"},{"jobs":"' + jobs + '"}]');
			changed = false;

			return fP;
		};


		function getJobs() {
			var jobsList = $('#jobsList')[0];
			var jobs = "";
			var len = jobsList.length;
			for (var i = 0; i < len; i++) {
				jobs += (jobsList[i].value + ((i != len) ? "|" : ""));
			}
			return jobs;
		}


		$(window).on('beforeunload', function(e) {
			if (changed == true) {
				return '{{unsavedStuff}}';
			}
		});


		$('input#fileName').focus(function() {
			var input = $(this);

		  if (input.val() == "") {
			  input.val(input.attr('placeholder'));
			  input.removeClass('placeholder');
			  changed = true;
		  }
	  })


	  var clockInput = $('.clockpicker-with-callbacks').clockpicker({
			donetext: ('Set'),
	  /*--------
			init: function() { 
				 console.log("colorpicker initiated");
			},
			beforeShow: function() {
				 console.log("before show");
			},
 ------*/
			afterShow: function() {
			  //  console.log("after show");
			},
  /*---------------
			beforeHide: function() {
				 console.log("before hide");
			},
			afterHide: function() {
				 console.log("after hide");
			},
			beforeHourSelect: function() {
				 console.log("before hour selected");
			},
			afterHourSelect: function() {
				 console.log("after hour selected");
			},
			beforeDone: function() {
				 console.log("before done");
			},
	  ----------*/
			afterDone: function(timeValue) {
			//	console.log("clockPicker --  time : " + timeValue + " menuTyp: " + menuType +" timeType >>" + timeType + "<<");

				var deco  = '<b>';
				var deco1 = '</b>';


				if (menuType == 'ON') {
					setON = timeValue;
					setButton ('ON', '{{ON}}', deco, deco1, modeON + " " + timeValue);
				}

				if (menuType == 'ONoffset') {
					setONoffset = timeValue;
					setButton ('ONoffset', '{{ONoffset}}', deco, deco1, modeONoffset + " " + timeValue);
				 }


				if (menuType == 'OFF') {
					setOFF = timeValue;
					setButton ('OFF', '{{OFF}}', deco, deco1, modeOFF + " " + timeValue);
				}

				if (menuType == 'OFFoffset') {
					setOFFoffset = timeValue;
					setButton ('OFFoffset', '{{OFFoffset}}', deco, deco1, modeOFFoffset + " " + timeValue);
				}

				buildJob(true);
	//			$('#timeClock').attr('style', 'display:none');

			}
	});

	// Manually toggle to the minutes view
	$('#check-minutes').click(function(e){
		// Have to stop propagation here
		e.stopPropagation();
		clockInput.clockpicker('show')
			.clockpicker('toggleView', 'minutes');
	});

	</script>

	</body>
</html>
