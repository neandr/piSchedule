<!DOCTYPE html>
<html lang="de">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">

		<title>piSchedule `Actual Day Schedule`</title>
		<!-- /cVersion/16-09-10_0/ -->

		<!-- optional: Einbinden der jQuery-Bibliothek -->
		<script src="https://code.jquery.com/jquery-1.11.2.min.js"></script>

		<!-- bootstrap downloaded and minified JS/CSS -->
		<link rel="stylesheet" href="static/bootstrap.min.css">
		<link rel="stylesheet" href="static/bootstrap-theme.min.css">
		<script src="static/bootstrap.min.js"></script>

		<script src="static/pi.docs.js"></script>
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

					<td align="right"><small>
						<a role="menuitem" id="piScheduleNews" style="cursor:pointer;{{newsDisplay}}" ><i>piSchedule</i> <b>News </b> &&newsDate&&</a>
					</small></td>

				</tr>
			</tbody>
		</table>

		<ul class="nav nav-pills">

			<li role="presentation" class="dropdown active">
				<a class="dropdown-toggle" data-toggle="dropdown"  role="button" aria-expanded="false" 
					href="#"  title="{{iniLoading}}">{{iniFile}} &nbsp; <span class="caret"></span>
				</a>
				<ul id="editMenu" class="dropdown-menu" role="menu">
						&&iniFileList&&
				</ul>
			</li>

			<li  role="presentation"><a title="{{refreshText}}" href='/refresh'>
				<img src="/static/grefresh.png" style="width:18px; margin-right:4px"></a>
			</li>

			<li role="presentation"><a title="Show Jobs on Timeline"  href='/timeline'>
				<img src="/static/timeline.png" style="height:20px"></a>
			</li>

			<li role="presentation"><a href="/logs">{{dayLogs}}</a></li>

			<li role="presentation"><a title="Open pilight"  href={{pilight}}>
				<img src="/static/pilight.png" style="height:20px"></a>
			</li>

			<li role="presentation" class='pull-right' style="padding-right: 10px;">
				<button class='btn btn-default btn-sm dropdown-toggle'
					 id ='addJob' title='{{addJob}}' type="button">
					 <img title='Add a new job.' src='/static/gplus.png' style='width:18px'>
				</button>
			</li>

			<a role="menuitem" title="Show details for 'Day Schedule'" 
				class='pull-right' style="cursor:pointer; padding-right:30px; padding-top:4px;"
				id="dayPlanDefinition" onclick="docs.set(this)">
				<img src="/static/ginfo.png" style="width:24px">
			</a>
		</ul>

		&&timeTable&&

	</section>

	<!-- modal Dialog for piSchedule News  -->
	<div id="newsModal" class="modal fade" tabindex="-1" role="dialog" 
				aria-labelledby="newsLine" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">


				<div class="modal-header" style="padding-bottom:20px!important">
					<h4 class="modal-title" id="newsLabel"><i>piSchedule</i><b> News</b> 
						<ul class="nav nav-pills pull-right">
							<li role="presentation">
								<a style="cursor:pointer;padding-top: 4px;padding-bottom:5px;font-weight: bold" 
									data-dismiss="modal"> X </a>
							</li>
						</ul>
					</h4>
					<a role="menuitem" class='pull-right' style="cursor:pointer;" 
							id="callForum" onclick="docs.set(this)"><small><i>piSchedule</i> <b>Forum</b></small></a>
				</div>

				<p style="padding-left: 30px; padding-right: 100px;">
					&&news&& 
				</p>

				<div class="modal-footer" >
				</div>

			</div><!-- /.modal-content -->
		</div><!-- /.modal-dialog -->
	</div><!-- /newsModal -->


	<!-- modal Dialog for piHelp  -->
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

				<iframe id="frameHelp" src="" width="100%" onload="resizeIframe(this)"
					style="border:none"></iframe>

				<div class="modal-footer">
					<a role="menuitem" style="cursor:pointer;" 
						id="doRepeat" onclick="docs.set(this)">
						<img src="/static/grepeat.png" style="width:18px; margin-right:18px">
					</a>
				</div>

			</div><!-- /.modal-content -->
		</div><!-- /.modal-dialog -->
	</div><!-- /helpModal -->


	<script language="javascript" type="text/javascript">
		var language = "{{locale}}";
		var docAddress = docs.DBox + docs.Schedule + language + "/"

		console.log(" *** piSchedule - piSchedule : " + docAddress)


		function resizeIframe(obj) {
			obj.style.height = window.innerHeight * .6 + "px";
		}


		$("#piScheduleNews").click(function() {
			console.log(" .... piScheduleNews")
			$('#newsModal').modal('show');
		})

		$("#piScheduleNewsClose").click(function() {
			console.log(" .... piScheduleNews  close")
			setTimeout(function(){location.replace('/newsDate');},1);
		})


		$('#main').on('click', function(event) {
			location.replace('/home');
		});

		$('#addJob').on('click', function(event) {
			location.replace("/edit?addJob");
		});


		function setHSL(xThis, hStr, delay){
			setTimeout(function() {xThis.parentElement.parentElement.setAttribute('style',hStr)}, delay)
		}

		var newsWindow = null;

		function action(xThis){
			var info = xThis.id;

			if (info == 'news') {
				$('#newsModal').modal('show');
				return
			}


			if (info == 'removeJob') {  // button will be added with py
				console.log(" *** piSchedule -  Remove Job selected: " + xThis.parentElement.id);

				for (var n = 0; n < 10; n = n + 1) {
					var h = ("background-color:hsla(60, 100%, 50%, ." + n +")");
					setHSL(xThis, h, n*100);
				}
				setTimeout(function(){location.replace("/removeJob?" + (xThis.parentElement.id));},1000);
			}

		}

	</script>

	<style type="text/css">
			h3 {
				background: silver;
			}
	</style>

	</body>
</html>
