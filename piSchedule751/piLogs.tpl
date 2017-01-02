<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">

		<title>piSchedule Logs</title>
		<!-- /cVersion/16-09-10_0/ -->

		<!-- optional: Einbinden der jQuery-Bibliothek -->
		<script src="https://code.jquery.com/jquery-1.11.2.min.js"></script>

		<!-- bootstrap downloaded and minified JS/CSS -->
		<link rel="stylesheet" href="static/bootstrap.min.css">
		<link rel="stylesheet" href="static/bootstrap-theme.min.css">
		<script src="static/bootstrap.min.js"></script>

		<style type="text/css">
			h3 {
				background: silver;
			}

			h4 {
				background: silver;
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
		</style>

	</head>

	<body>

		<section class="container">

			<div class="container">

			<div class="jumbotron" 
				style="cursor:pointer; padding: 5px 0px; margin-bottom: 15px; margin-top: 10px;">
				<div class="container" id="home" title="Go to main">
					<big><b><i> piSchedule </i><small> -- {{dayList}}</small></b></big>
					<button class="btn btn-default btn-sm dropdown-toggle pull-right" type="button">
						<img title='Help details' src='/static/ghome.png' width='14'>
					</button>
				</div>
			</div>


			<ul class="nav nav-pills">

				<li role="presentation" class="active" id="formAction">
					<a href="/logs">{{Today}}</a>
				</li>

				<li role="presentation" class="dropdown">
					<a class="dropdown-toggle" data-toggle="dropdown" 
						 href="#" role="button" 
						 aria-expanded="false"> {{selectDay}} <span class="caret"></span> </a>
					<ul class="dropdown-menu" role="menu" id="daySelect">
						<li>
							<a href="/logs?Monday">{{Monday}}</a>
						</li>
						<li>
							<a href="/logs?Tuesday">{{Tuesday}}</a>
						</li>
						<li>
							<a href="/logs?Wednesday">{{Wednesday}}</a>
						</li>
						<li>
							<a href="/logs?Thursday">{{Thursday}}</a>
						</li>
						<li>
							<a href="/logs?Friday">{{Friday}}</a>
						</li>
						<li>
							<a href="/logs?Saturday">{{Saturday}}</a>
						</li>
						<li>
							<a href="/logs?Sunday">{{Sunday}}</a>
						</li>
					</ul>
				</li>
				<li role="presentation"><a href='/refresh'>&nbsp; &lt;&lt; &nbsp;&nbsp;{{back}}</a></li>
 
			</ul>

			<h4>&&currentDay&&</h4>

		</div>

	</section>

	<section class="container" id="logList">
		{{!logList}}
	</section>

	<script>
		$('#home').on('click', function(event) {
			location.replace('/')
		});

		// with page loading display "Today" logs
		$(document).ready(function() {
			var href = location.href;
			if (href.substring(8).split("/")[1] == "logs")
				$('#formAction').submit();
		});
		//  document.ready

	</script>

	</body>

</html>


