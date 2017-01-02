
<html lang="de">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	
	<title>piSchedule `About`</title>
		<!-- /cVersion/16-09-14_18/ -->

		<!-- optional: Einbinden der jQuery-Bibliothek -->
		<script src="https://code.jquery.com/jquery-1.11.2.min.js"></script>

		<!-- bootstrap downloaded and minified JS/CSS -->
		<link rel="stylesheet" href="static/bootstrap.min.css">
		<link rel="stylesheet" href="static/bootstrap-theme.min.css">
		<script src="static/bootstrap.min.js"></script>

</head>

<body>

	<section class="container">

		<div class="jumbotron" 
			style="cursor:pointer; padding: 5px 0px; margin-bottom: 15px; margin-top: 10px;">
			<div class="container" id="main" title="{{gotoMain}}">
				<big><b><i> piSchedule </i><small> -- About </small></b></big>
				<button class="btn btn-default btn-sm dropdown-toggle pull-right" type="button">
					<img title='Help details' src='/static/ghome.png' width='14'>
				</button>
			</div>
		</div>

		<ul class="nav nav-pills">
			<li class="pull-right" role="presentation"><a href='/home'>&nbsp;
					&lt;&lt; &nbsp;&nbsp;{{back}}</a></li>
		</ul>
	</section>


	<section class="container">

		<div class="container">
			<h4 style="padding-left: 10px; padding-right: 100px;">
			Installation Details</h4>

			<p id="aboutPrefs" style="margin-left: 30px;">
				<!--
				  'version': xP.prefs['version'],
				  'pilightVersion': xP.prefs['pilightVersion'],
				  'server': xP.prefs['server'],
				  'port': xP.prefs['port'],
				  'locale': xP.prefs['locale']
				-->
				Versions - piSchedule : {{version}}/{{locale}}, pilight : {{pilightVersion}}<br>
				Server:Port: {{server}}:{{port}}<br>
				{{platform}}

			</p>

		</div>
	</section>


	<section class="container">

		<div class="container">
			<h4 title="Forum" style="padding-left: 10px; padding-right: 100px;">
				<i>piSchedule </i> Forum
				<a
					class="btn btn-default btn-sm pull-right" id="mailto1"
					onclick="openUrl('https://groups.google.com/forum/#!forum/piSchedule7')"
					title="Öffne piSchedule Forum" role="button">Öffnen des Forums</a>
			</h4>

			<p style="padding-left: 30px; padding-right: 100px;">
				Dieses Forum bietet den <i>piSchedule </i> Anwendern die Möglichkeit auf
				ihre Fragen Antworten zu erhalten, Empfehlungen zu geben. Über das
				Forum ist der Erfahrungsaustausch und auch mit anderen Anwendern
				möglich. So bildet sich - neben der Dokumentation - eine zusätzliche
				Informationsquelle für <i>piSchedule </i>. 
				<br><br> Das Forum ist von
				jedermann aufrufbar, Beiträge werden per E-Mail gesandt und
				moderiert -- dies um Spam zu vermeiden. Bitte vor einem neuen
				Forumsbeitrag prüfen, ob das Thema schon bearbeitet wurde. 
			</p>
		</div>

		<div class="container">
			<h4 title="Öffne eine E-Mail Vorlage" style="padding-left: 30px; padding-right: 100px;">
				Neuer <i>piSchedule </i> Forumsbeitrag
				<a
					class="btn btn-default btn-sm pull-right" id="mailto1"
					onclick="go2ask('piSch%65dule&#55;%','Ecom', 'g%6Fogl%65groups')"
					title="mailto:piScheduleForum" role="button">Forums
					Beitrag</a>
			</h4>

			<p style="padding-left: 50px; padding-right: 100px;">
				<i><b>Hinweis:</b> Hierbei werden piSchedule/pilight
					Installationsinformation in eine E-Mail Vorlage übernommen. Ist
					gewünscht, dass dies nicht übertragen wird, können die Einträge in
					der Vorlage gelöscht werden.</i>
			</p>

			<p style="padding-left: 30px; padding-right: 100px;">

				Alternativer Versand eines E-Mail an den Entwickler 
				(bzgl. der Installationsinformationen gilt gleiches).
				<a
					class="btn btn-default btn-sm pull-right" id="mailto1"
					onclick="go2ask('gn%65andr%', 'Ed%65', '%77eb')" title="mailto:developer"
					role="button">E-Mail</a>
			</p>




			<!--
			<p style="padding-left: 30px; padding-right: 100px;">
				If our documentation doesn&#8217;t solve your problem, the <strong><a
					href="https://groups.google.com/forum/#!forum/piSchedule7"><i>piSchedule</i>
						Forum</a></strong> is an additional resource. Users post their questions there
				and get answers and recommendations also from other users. Probably
				you find an answer already there. Basically it&#8217;s the best
				place to ask questions, report problems, or leave comments.
			</p>

			<p style="padding-left: 50px; padding-right: 100px;">
				<em>Please make sure to check for similar points you have
					before post or mail to the Forum.</em>
			</p>

			<p style="padding-left: 30px; padding-right: 100px;">
				You can also send a request using your favorite mail system. This
				will include some details about your installation which helps to
				understand your situation.
				<a
					class="btn btn-default btn-sm pull-right" id="mailto1"
					onclick="go2ask('piSch%65dule&#55;%','Ecom', 'g%6Fogl%65groups')"
					title="mailto:piScheduleForum" role="button">Forum</a>
			</p>

			<p style="padding-left: 50px; padding-right: 100px;">
				<em>Please note that this is a public mailing list; other list
					members may reply with help, and your message (including your
					e-mail address) will be archived in the mailing list archives.</em>
			</p>

		</div>

		<div class="container">

			<h4 title="Contact">
				Contact a Developer
			</h4>
			<p style="padding-left: 30px; padding-right: 100px;">
				If you don&#8217;t want to send a message to the mailing list, feel
				free to contact us directly.
				<a
					class="btn btn-default btn-sm pull-right" id="mailto1"
					onclick="go2ask('gn%65andr%', 'Ed%65', '%77eb')" title="mailto:developer"
					role="button">Development</a>
			</p>

		</div>
-->
	</section>


	<script>
		$('#main').on('click', function(event) {
			location.replace('/home')
		});

		var browser = ""

		// with page loading build ....
		$(document).ready(function() {
			browser = navigator.userAgent + " (" + navigator.language + ")";
		});

		function loadJobs(fName) {
			$.get('/removeJobs');
			$.ajaxSetup({
				async : false
			});
			$.get(('/schedule?' + fName));
			$.ajaxSetup({
				async : true
			});
			$.get('/locale?DE');
		}


		function go2ask(addr, addr2, addr1) {
			var subject = " ?? bitte angeben ..  "; // Feedback / Support Request ... ";
			var body = "Feedback / Support Request : \n" 
				 + " ** Please  set an appropriate 'Subject'! ** "
				 + "\n\n\n\n___________________________________________________\n"
				 + "Versions - piSchedule : {{version}}/{{locale}}/{{geo}}, pilight : {{pilightVersion}}\n"
				 + "piSchedule server:port: {{server}}:{{port}};	INI File: {{iniFile}}\n"
				 + "{{platform}}\n"
				 + browser 

			var mailtoUrl = "mail"+ "to" + ":" + addr + "40" + addr1 + "%2" + addr2;
			mailtoUrl += "?subject=" + encodeURIComponent(subject);
			mailtoUrl += "&body=" + encodeURIComponent(body);

			window.location.href = mailtoUrl;
		}

		function openUrl(name) {
			window.open(name)
		}

	</script>

</body>
</html>
