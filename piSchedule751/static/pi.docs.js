	var _page = null;
	var _link = "";
	var _lastInfo = "";
	var _sDoc = null;
	var _newsWindow = null;


	var docs = {
	// ***** Customize lines for individual use ***********
		forum: "https://groups.google.com/forum/#!forum/pischedule7",


		DBox: "https://neandr.github.io/piSchedule/",

		news: 'news751.txt',

		Overview: "overview75.html",
		timeline: "timeline.html",
		Edit: "scheduleEdit.html",
		Examples: "scheduleExamples.html",
		Features: "scheduleFeatures.html",


	// ***** DO NOT  change lines below ****

		// open a new window to show a docu page, if the page isn't define
		// open the main docu page with a bookmark
		open : function(name) {
			_link = this.DBox + language.toLowerCase() +'.';

		console.log(" *** piSchedule - pi.docs.open     name: " + name
			+ " link:: " + _link);

			if (_page != null) {_page.close()}
			switch (name) {
				case 'Overview': 
				case 'Edit':     
				case 'timeline': 
				case 'Examples': 
				case 'Features': 
					_page = window.open(_link + docs[name], 'docu');break;

				default:
					_page = window.open(_link + this.Overview + "#" + name, 'docu');break;
			}
		},

		// open a modal window to show main docu page with a bookmark;
		// modal window has two icons to 
		//   -- reposition the docu at the bookmark
		//   -- open the docu on a separte window
		set :  function (xThis, sDoc) {
			var info = xThis.id;
			_link = this.DBox + language.toLowerCase() + ".";

		console.log(" *** piSchedule - pi.docs.set     info: " + info  + "  sDoc:: " + _sDoc);

			switch (info) {

				case 'callForum':
					if (_newsWindow != null) {
						_newsWindow.close();
					}
					_newsWindow = window.open(this.forum,"forum");
				break;

				case 'doRepeat':
					var doc = _link + _sDoc + "#" + _lastInfo;
		console.log(" *** piSchedule - pi.docs.set     doRepeat: " + "  doc:: " + doc)

					$('#frameHelp')[0].setAttribute('src', "");
					setTimeout(function() 
						{$('#frameHelp')[0].setAttribute('src', doc)}, 1);
					break;

				case 'goBook': 
					var doc = _link + _sDoc + "#" + _lastInfo;
		console.log(" *** piSchedule - pi.docs.set     goBook: " + "  lastInfo:: " + _lastInfo + "  doc:: " + doc)

					window.open(doc, 'docu');break;
					break;

				default:
					_lastInfo = info;
					_sDoc = (sDoc == null) ? this.Overview : this[sDoc]
					var doc = _link + _sDoc + "#" + info;
		console.log(" *** piSchedule - pi.docs.set     default: " + doc  + "  lastInfo:: " + _lastInfo)


					$('#frameHelp')[0].setAttribute('src', "");
					setTimeout(function() {
						$('#frameHelp')[0].setAttribute('src', doc)}, 1);
					$('#helpModal').modal('show');
			}
		}

	}
