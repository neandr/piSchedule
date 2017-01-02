/*
 * 
 * MOD  gW                           TL.timelineDEV.16-09-08_10.js
 *         Timeline for piSchedule
 * 
 */
	jobsChanged = false;

(function ($) {

	/////////////////////
	// MAIN ENTRY POINT
	/////////////////////

	var Timeline = function (selector) {
if(log) console.log( "-->> Timeline-Selector setup -- selector ", selector);

		return  new Timeline($(selector));
	};

	window.Timeline = Timeline;

	var colors = {
		tic: "#E1E3D3",
		sunText: "#A6A7AD",
		sunBack: "#FBFCD2",
		sundark: "#C2C2CC",
		legend:  "#7A6DE8",
		onoff:   "#fc9b11",    //"#FCC323",   // #FCCC47",   // blue",
		onoff1:  "#fad379",    // "#FAE19D"
		ondelta: "#57fe6f",    // "#47FC71",   // yellow",
		offdelta: "#5771ff"    // "#4778FC"   // green"
	}

	var em = 10;
	var Options = {
		timeCursorTime: new Date(),
		device: "Kueche",
		selectedJOBs: {},

		textHeight: 1.6*em,
		jobHeight: 5*em,
		legend: 2,       //0=   1=   2=   ;
		log: false,
		info: true,
		warn: true,
	};

	//enable/disable console logger
	var log = false;
	var info = true;
	var warn = true;
	var debug = true;


	///////////////////
	// TIMELINE CLASS
	///////////////////;

	var Timeline = function (container) {
		this.container = container;
	};


	// Configuration ___________________________

	// sunString      timeString  or 'sunrise' or 'sunset'
	Timeline.prototype.sunrise = function (sunString) {
		Options.sunrise = sunString;
		return this;
	};

	Timeline.prototype.sunset = function (sunString) {
		Options.sunset = sunString;
		return this;
	};


	// timeString   hh:mm:ss
	Timeline.prototype.startTime = function (timeString) {
	//	Options.startTime = (timeString);
		Options.startTime = this.timeSetter(timeString);
		return this;
	};

	Timeline.prototype.endTime = function (timeString) {
		Options.endTime = this.timeSetter(timeString);
	//	Options.endTime = (timeString);
		return this;
	};


	// dateString   YYYY-MM-DD )
	Timeline.prototype.startDate = function (dateString) {
		Options.startDate = this.dateSetter(dateString);
		return this;
	};

	Timeline.prototype.endDate = function (dateString) {
		Options.endDate = this.dateSetter(dateString);
		return this;
	};

	// _____________________ Configuration


	// Methods ______________________

	Timeline.prototype.cursorHandler = function (evt) {

		var jobID =  evt.target.id;
		var job =  jobID.split('_')[0];
		var instance = evt.target.id.split('_')[1];

	if(info) console.info("  ..cursorHandler .. jobID:", jobID, " instance: ", instance, " --> job:", job, "  jobCursorLast:",jobCursorLast)

		if (job == "jobsBox") jobCursorLast = false;

		if (instance != null) {

			d3.select("#" +"OnCursor").remove()
			d3.select("#" +"OffCursor").remove()
			d3.select("#" +"RonCursor").remove()
			d3.select("#" +"RoffCursor").remove()

			if (instance == 'X') {
				// direct edit of Job string

				var textContent = evt.target.textContent.split(':\\')
				var jobNo = textContent[0]
				var job = textContent[1]

				document.getElementById("pickJob").setAttribute('jobNo',jobNo);
				document.getElementById("pickJob").value =  job;
				document.getElementById("jobNoEdit").textContent = "Job # " + jobNo;

				$('#editPlan').modal('show');
				return;
			}

			var x =  $("#" + jobID)

			var xPos, xWidth, xHeight; var offCursor = true;
			var xItem = x[0].className.baseVal;

			if (xItem == 'rect') {
				xPos = x[0].x.baseVal.value;
				xWidth = x[0].width.baseVal.value;
				xHeight = x[0].y.baseVal.value;
			}

			if (xItem == 'circle') {
				xPos = x[0].cx.baseVal.value;
				xWidth = 0;
				xHeight = x[0].cy.baseVal.value;
				offCursor = false;
			}
			this.jobCursors(xPos, xWidth, xHeight, offCursor, job, instance)
			jobCursorLast = true
		}

			else {   // blue timeCursor with hh:min label ____

			if (jobCursorLast == true) return

			var hstart = Options.startTime.hh;
			var hend = Options.endTime.hh;

			var x = (evt.clientX - evt.currentTarget.offsetLeft - Options.PaddingX)
			var xTime = x/Options.width * (hend-hstart) + hstart
			var hh = n2(Math.floor(xTime))
			var min = n2(Math.floor(Math.floor((xTime - hh)*100)*.6))

//	if(info) console.info("  is blue cursor  ", hh, ":", min, xTime, "\n  ", evt.clientX, "\n    ", hstart, hend, Options.width, Options.PaddingX)


			var tCursorPos = [{ x: 0, y: 0 }];

			$("#timeCursor").first().remove()
			var timeMarker2 = d3.select("#timeCursorGroup")
				.append("svg:svg")
				.attr("id", "timeCursor")
				.attr("jobName", "timeCursor")

				.data(tCursorPos)
				.append("g")
				.attr("transform", 
					function (tCursorPos) { return "translate(" + tCursorPos.x + "," + tCursorPos.y + ")"; })
				.call(this.onDragDrop(this.dragmove, this.dropHandler, "timeCursorTXT" /*dSource*/));


			x = (evt.clientX -evt.currentTarget.offsetLeft)
			var tic0 = Options.textHeight +2;
			var tic1 = Options.outerHeight;


			//textColored = function (parent, text, idTxt, anchor, xT, yT, textColor, fillColor) 
			this.textColored (timeMarker2, (hh + ":" + min /*+ " | " + x*/ ) /*text*/, 					//XXXXXX  x Wert zeigt Position
				'timeCursor' /*idTxt*/, 'middle' /*anchor*/, x/*xT*/, tic0 -2 /*yT*/,
				"blue" /*textColor*/, colors.sunBack /*fillColor*/);

			var nowTic = $svg.line(
				x, tic0, x, tic1
			)
				.attr("class", "timeCursorLINE")
				.attr("stroke", "blue")
				.attr("stroke-width", 1)
				.appendTo(timeMarker2);
			// draw hh:mm and a line for the time ____ 
			return;
			// _______ blue timeCursor with hh:min label ____

		}

	}

	// Job cursor ON/OFF
	Timeline.prototype.jobCursors = function (xPos, xWidth, xHeight, offCursor, xJob, instance) {

	if(info) console.info("  jobCursors    start   xJob:", xJob, "  instance:", instance, "  offCursor:", offCursor)

		var yH = xHeight - Options.textHeight

		var hstart = (Options.startTime).hh;
		var hend = (Options.endTime).hh;

		if (instance == 'On') {
			var onTime = (xPos - Options.PaddingX)/Options.width * (hend-hstart) + hstart
			var hhOn = n2(Math.floor(onTime))
			var mnOn = n2(Math.floor(Math.round((onTime - hhOn)*100)*.6))

		//	this.jobCorsorWorker ($("#" + xJob), (hhOn + ":" + mnOn) /*text*/, 
			this.jobCorsorWorker ( xJob, (hhOn + ":" + mnOn /*+ " | "+ xPos */) /*text*/, 
				instance + "Cursor" /*idTxt*/, "middle" /*anchor*/, xPos /*xT*/, xHeight /*yT*/,
				"red" /*textColor*/, colors.sunBack /*fillColor*/, "blue" /*cursorColor*/, instance);
		}

		if ((offCursor == true) || (instance == 'Off')) {
			var offTime = (xPos + xWidth - Options.PaddingX)/Options.width * (hend-hstart) + hstart
			var hhOff = n2(Math.floor(offTime))
			var mmOff = n2(Math.floor(Math.round((offTime - hhOff)*100)*.6))

			this.jobCorsorWorker (xJob, (hhOff + ":" + mmOff) /*text*/, 
				'Off' + "Cursor" /*idTxt*/, "middle" /*anchor*/, xPos + xWidth /*xT*/, xHeight /*yT*/,
				"red" /*textColor*/, colors.sunBack /*fillColor*/, "black" /*cursorColor*/, instance);
		}

		jobCursorLast = true
	}

	var jobCursorLast = false;


	Timeline.prototype.work = function (mData) {
		for (var m in mData) {
			if (m == 'log') {
				log = mData[m];
			}

			if ((m == 'startTime') || (m == 'endTime')) {
				Options[m] = this.timeSetter(mData[m])
			} else {
				Options[m] = mData[m];
			}

			if ((m == 'updateJob')) {
				var jobStr = mData[m]

				var jobNo = jobStr.split('||')[0]
				var job = jobStr.split('||')[1]
				var newJobs = stripAll(Options.device +";" + job);

				var jobsPosition = getJobsString (Options.device, jobNo) 
				var currentJobs = Options.xjobs[jobsPosition]

				var msg = ("\nNew Job >>" + newJobs + "<<  jobsPosition:" +  jobsPosition 
					      + "\nOld     >>" + currentJobs + "<<")
		console.log(" change job string ", msg)

				Options.xjobs[jobsPosition] =  newJobs;
				jobsChangeSet (true);
			}
		}

		/*
		 * add a new job *before* the selected job
		 */
		if ((m == 'addJob')) {
// .work({addJob: (pJob[0].attributes.jobno.value + "||" + pJob[0].value)})
			var jobStr = mData[m];

			var jobNo = jobStr.split('||')[0];
			var job = jobStr.split('||')[1];
			var jobsPosition = getJobsString (Options.device, jobNo);

			Options.xjobs = addObjectN (Options.xjobs, jobsPosition, Options.device +";" + job);

			jobsChangeSet (true);
		}


		/*
		 * delete the selected job
		 */
		if ((m == 'deleteJob')) {
// .work({deleteJob: (pJob[0].attributes.jobno.value })
			var jobNo = mData[m];
			var jobsPosition = getJobsString (Options.device, jobNo);
			Options.xjobs = removeObjectN (Options.xjobs, jobsPosition);

			jobsChangeSet (true);
		}


		/*
		 *   change the left/right position of the Legend or switch off
		 */
		if (Options.changeLegend) {
				Options.legend++;
				if (Options.legend == 3) Options.legend = 0;
			Options.changeLegend = null;
		}


		var a = 0; e = 0;
		if (Options.timeScale == 'left')  {a = -1; e = -1}
		if (Options.timeScale == 'right') {a = 1; e = 1}

		if (Options.timeScale == '++') {a = 1; e = -1}
		if (Options.timeScale == '--') {a = -1; e = +1}

		var ahh = Options.startTime.hh + a
		if (ahh > 24) ahh =24
		if (ahh < 0) ahh = 0

		var ehh = Options.endTime.hh + e
		if (ehh > 24) ehh =24
		if (ehh < 0) ehh = 0

		if ((ehh - ahh) >= 1) {
			Options.startTime = this.timeSetter(ahh +":00:00")
			Options.endTime = this.timeSetter(ehh +":00:00")
		}

		Options.timeScale = ""

		$("#jobsBox").first().remove()
		this.draw();
	}


	Timeline.prototype.xoptions = function (mData) {
		for (var m in mData) {

			if (m == 'log') {log = mData[m];}
			if (m == 'info') {info = mData[m];}
			if (m == 'warn') {warn = mData[m];}
			if (m == 'debug') {debug = mData[m];}

			// get jobs for current day agenda
			if (m == 'xjobs') { // 
				Options[m] = mData[m];
				Options.xjobs= []
				var xjobs = mData[m].split("||")
				for (var nj = 0; nj < xjobs.length; nj++){
					Options.xjobs.push(xjobs[nj])
				}

			} else {
				Options[m] = mData[m];
			}
		}

		$("#jobsBox").first().remove();
		this.draw();
	}


	Timeline.prototype.saveJobs = function (fileName) {
			var fN = $('input#fileName').val()
			var fP = $('input#fileName').attr('placeholder')

			var jobs = Options.xjobs.join("|").replace(";|","|");

console.log("   saveJobs   fN:", fN, fP, fileName, "\n  jobs:\n", jobs)
//  return 			//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

			$.get('/fSave?[{"fName":"' + fN + '"},{"pName":"' + fP
					+ '"},{"jobs":"' + jobs + '"}]');

			jobsChangeSet (false);
		};

	// _________________ Methods



	// Rendering _____________________
	Timeline.prototype.draw = function () {

		var nJob = 0; var xJobLine; var device;
		var xjobsLines = Options.xjobs.length;

		// check no of devices, skip for empty lines
		if (Options.xjobs && xjobsLines > 0) {
			for (var e = 0; e < xjobsLines; e++) {
				xJobLine = stripAll(Options.xjobs[e]);
				device = xJobLine.split(";")[0]

				if ((!device) || (device == "")) continue
				if (Options.device != device) continue
				nJob++
			}
		}

		// draw background for the number of jobs found
		this.drawBackground(nJob);

		this.drawJobs();

		this.nowMarker = $svg.group()
			.attr("class", "nowCursorGroup")
			.attr("id", "nowCursorGroup")
			.appendTo(this.svg);

		this.timeMarker = $svg.group()
			.attr("class", "timeCursorGroup")
			.attr("id", "timeCursorGroup")
			.appendTo(this.svg);

		this.drawTimeCursor ();	// draw a red cursor to show current time

		return this;
	};



	// ____ draw Background
	Timeline.prototype.drawBackground = function (nJobs) {

		var jHeight = Options.jobHeight*(nJobs+1);

		this.outerWidth = this.container.innerWidth();
		Options.outerHeight = jHeight;
		Options.PaddingX = 10;
		Options.PaddingY = 10;

		Options.width = this.outerWidth - ( Options.PaddingX* 2);
		Options.height = Options.outerHeight - (Options.PaddingY* 2);

		this.container.height(Options.outerHeight);

		this.svg = $(svg("svg"))
			.attr("id", "jobsBox")
			.attr("width", this.outerWidth)
			.attr("height", Options.outerHeight)
			.appendTo(this.container);

		var background = $svg.group()
			.attr("class", "background")
			.attr("id", "tBackground")
			.appendTo(this.svg);

		// draw baseline
		var baseline = $svg.line(
			Options.PaddingX,
			Options.textHeight + 3,
			Options.width + Options.PaddingX,
			Options.textHeight + 3
		)
			.attr("stroke", colors.tic)
			.attr("stroke-width", 1)
			.appendTo(background);


		//Draw the labels and ticks _________
		var tic0 = Options.textHeight +2;
		var tic1 = Options.outerHeight;

		for (var hh = (Options.startTime).hh; hh <= (Options.endTime).hh; hh++) {
			var x = (this.getXhour(hh));

			var isMajorTick = (hh % 3 === 0);
			if (isMajorTick) {	 // write hour number as text 
				var hourLabel = $svg.text( 'hh'+hh,
					x,
					Options.textHeight,  // Options.PaddingY -1,
					hh+":00",
					{
						fill:  colors.legend,      //"blue",
						"font-size": .8*Options.textHeight,
						"text-anchor": "middle"
					}
				)
					.appendTo(background);
			} // write hour number as text 

			var hourTick = $svg.line(
				x, tic0, x, tic1
			)
				.attr("stroke", colors.tic)
				.attr("stroke-width", 1)
				.appendTo(background);
		}// __________ Draw the labels and ticks 

		var xr, xs, xe, xTime;
		var yLabels =  2*Options.textHeight;

		// draw sunrise box at left
		if (Options.sunrise != null) {
			xTime = this.timeSetter(Options.sunrise);
			xr = this.getXhour(xTime.hh + xTime.mm/60);

			var sunriseRect = $svg.rect(
				0, 0, xr, Options.outerHeight
			)
				.attr("fill", colors.sundark)
				.attr("fill-opacity",0.1)
				.appendTo(background);

			//textColored = function (parent, text, idTxt, anchor, xT, yT, textColor, fillColor) 
			this.textColored (background, ("Sunrise " + n2(xTime.hh)+":"+n2(xTime.mm)) /*text*/, 
				'sunrise' /*idTxt*/, 'end' /*anchor*/, xr /*xT*/, yLabels/*yT*/,
				colors.sunText /*textColor*/, colors.sunBack /*fillColor*/);
		}

		// draw sunset box at right
		if (Options.sunset != null) {
			xTime = this.timeSetter(Options.sunset);
			xs = (this.getXhour(xTime.hh + xTime.mm/60));
			xe = this.getXhour((Options.endTime).hh);

			var sunriseRect = $svg.rect(
				xs, 0, xe, Options.outerHeight
			)
				.attr("fill", colors.sundark)
				.attr("fill-opacity",0.1)
				.appendTo(background);

			//textColored = function (parent, text, idTxt, anchor, xT, yT, textColor, fillColor) 
			this.textColored (background, (n2(xTime.hh)+":"+n2(xTime.mm) + " Sunset") /*text*/, 
				'sunset' /*idTxt*/, 'start' , xs /*xT*/, yLabels /*yT*/,
				colors.sunText /*textColor*/, colors.sunBack /*fillColor*/); 
		}

		return this;
	};	// draw Background ___


	Timeline.prototype.timeCursor = function (xEvent) {
		var iTime = Options.timeCursorTime
		var mins = Options.timeCursorTime.getMinutes() +5
		iTime = new Date(Options.timeCursorTime.setMinutes(mins))
		this.drawTimeCursor (iTime) 
	}


	// ___ draw hh:mm and a red line for time
	Timeline.prototype.drawTimeCursor = function (dTime) {

		$("#nowCursor").first().remove()
		var nowCursorGroup = $("#nowCursorGroup")

		var timeMarker2 = $svg.group()
			.attr("class", "group")
			.attr("id", "nowCursor")
			.attr('style', "cursor:pointer")
			.attr('onclick', "timeCursor()")
			.appendTo(nowCursorGroup);

		var tic0 = Options.textHeight +2;
		var tic1 = Options.outerHeight;

		// time value was passed use it OR use actual time
		if (dTime != null) {
			Options.timeCursorTime = dTime
		} else {
			Options.timeCursorTime = new Date()
		}

		var th = n2(Options.timeCursorTime.getHours())
		var tm = n2(Options.timeCursorTime.getMinutes())
		var x = (this.getXhour( +th + +tm/60));

		//textColored = function (parent, text, idTxt, anchor, xT, yT, textColor, fillColor) 
		this.textColored (timeMarker2, (th + ":" + tm) /*text*/, 
			'nowCursor' /*idTxt*/, 'middle' /*anchor*/, x/*xT*/, tic0 -2 /*yT*/,
			"red" /*textColor*/, colors.sunBack /*fillColor*/);

		var nowTic = $svg.line(
			x, tic0, x, tic1
		)
			.attr("class", "nowCursorLINE")
			.attr("stroke", "red")
			.attr("stroke-width", 1)
			.appendTo(timeMarker2);
		// draw hh:mm and a red line for the actual time ____ 
		return;
	};



	Timeline.prototype.drawJobs = function () {

		var jobsGroup = $svg.group()
			.attr("class", "jobsGroup")
			.attr("id", "jobsGroup")
			.appendTo(this.svg);

		var xDevice = Options.device;
		var jobs = Options.xjobs;

		Options.selectedJOBs = [];

		// piSchedule job string
		var nJob = 0; var xJob; var xDevice;
		var nselect =0;
		if (jobs && jobs.length >0) {
			for (var e = 0; e < jobs.length; e++) {
				xJob = stripAll(jobs[e]);
				xDevice = xJob.split(";")[0];

				if ((!xDevice) || (xDevice == "")) continue;
				if (Options.device != xDevice) continue;

				var JOB = this.scheduleSet(xJob);
	if(info) console.info(" scheduleSet(xJob)", JOB);
				if (JOB.ERR) {
					console.error(" piSchedule Timeline ", JOB.ERR, " job:", xJob);
					continue;
				}

				Options.selectedJOBs[nselect] = JOB;
				nselect++;

				var jobGroup = $svg.group()
					.attr("class", "jobGroup")
					.attr("id", JOB.device + nJob + "GROUP")
					.appendTo(jobsGroup)   //this.svg);

				this.drawJob(JOB, nJob, jobGroup);
				nJob++
			}
console.log(" ***** drawJobs: \n", Options.selectedJOBs)
		}
	};



	Timeline.prototype.drawJob = function (JOB, noJob, jobGroup) {

		var group, rect, circle, jobText;
		var jobONtext = jobOFFtext = "";

		var jobName = (JOB.device + noJob).replace(" ","").replace(":","");
		var s = Options.startTime.fTime;

	if(info) console.info("     draw Job #:", noJob, JOB.device, JOB.JOBs, "\n  -- jobGroup   ", jobGroup)

		if (!!JOB.ON) {
			if (!!JOB.ON.sun) {
				jobONtext += (',' + JOB.ON.sun);
			} else {
				jobONtext += (',' + JOB.ON.time);
			}
			if (!!JOB.ON.deltaTime) jobONtext += ',' + JOB.ON.deltaSign + JOB.ON.deltaTime
			if (!!JOB.ON.randomTime) jobONtext += ',~' + JOB.ON.randomSign + JOB.ON.randomTime
		}

		if (!!JOB.OFF) {
			if (!!JOB.OFF.sun) {
				jobOFFtext += (',' + JOB.OFF.sun);
			} else {
				jobOFFtext += (!!JOB.OFF.time) ? (',' + JOB.OFF.time) : "";
			}
			if (!!JOB.OFF.deltaTime) jobOFFtext += ',' + JOB.OFF.deltaSign + JOB.OFF.deltaTime
			if (!!JOB.OFF.randomTime) jobOFFtext += ',~' + JOB.OFF.randomSign + JOB.OFF.randomTime
		}

		jobText = noJob + ":\\ " + ((jobONtext == "") ? "" : "on" + jobONtext); 
		jobText += ((jobONtext == "") ? "" : ";");
		jobText += ((jobOFFtext == "") ? "" : ("off" + jobOFFtext)); 

	if(log) console.info(  "  .. ON  :  ", JOB.ON, "\n  .. OFF :  ", JOB.OFF)

		var H1 = ein0 = aus0 = ein1 = aus1 = ausT = 0; einT = 10000;
		var einDelta = einRandom = ausDelta = ausRandom = 0;

		var offset = 	Options.PaddingX;

		if (!!JOB.ON) {
			ein0 = JOB.ON.fTime;
			einDelta = (JOB.ON.fDeltaTime);
			einRandom = (JOB.ON.fRandomTime);
			H1 = (this.getXhour(ein0 + 1) - this.getXhour(ein0))
		}

		if (!!JOB.OFF) {
			aus0 = (JOB.OFF.fTime == 0) ? ein0 : JOB.OFF.fTime
			ausDelta = (JOB.OFF.fDeltaTime);
			ausRandom = (JOB.OFF.fRandomTime);
			H1 = (this.getXhour(aus0 + 1) - this.getXhour(aus0))
		}

	if (info) {
		console.info("  ____________   #", noJob, JOB.device, "_____ ", JOB.JOBs);
		console.info("   ein:", ein0, einDelta, einRandom, "\n   aus:", aus0, ausDelta, ausRandom, " start:", s,
		"\n  points    x:", this.getXhour(ein0), "   y:", this.getXhour(aus0),
		"\n           H1:", (this.getXhour(ein0 + 1) - this.getXhour(ein0)))
	}

// return;				//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		var x, d;

		group = $svg.group()
			.attr("id", jobName)
			.attr("jobNo", noJob)
			.attr("name", JOB.device)
			.appendTo(jobGroup);    //this.svg);

		var pH = Options.PaddingY  + (+noJob+1)*Options.jobHeight;

		// --- ON/OFF box ___________________
		if ((!!JOB.ON && !!JOB.ON.fTime) && (!!JOB.OFF)) {

			ein2 = (ein0 - s + einDelta + einRandom)*H1 + offset;
			d = (aus0 + ausDelta - (ein0 + einDelta))*H1;

			rect = $svg.rect(
				ein2, pH, d, Options.textHeight)
				.attr("class", "rect")
				.attr("id", jobName + "_On1")
				.attr("fill", colors.onoff1)
				.attr("title", (jobText))
				.appendTo(group);

			x = (ein0 - s + einDelta)*H1 + offset;

			einT = x;
			ausT = x + d
console.log(" ON/OFF box:", ein2, d, "  ein0:", ein0, einDelta, ausDelta, " TTT:", einT, ausT);

			rect = $svg.rect(
				x ,  pH  + .9*em, d, (Options.textHeight)
			)
				.attr("class", "rect")
				.attr("id", jobName + "_On")
				.attr("fill", colors.onoff)
				.attr("title", (jobText))
				.appendTo(group);
		}

		// ---  ON random box ______________
		if (!!JOB.ON && !!JOB.ON.randomTime) {
			ein1 = (ein0 -s + einDelta)*H1 + offset;
			d = einRandom *H1;
			if (d < 0) {
				ein1 = ein1 +d;
				d = -d;
			}
			einT = (ein1 < einT)? ein1 : einT;
			ausT = (aus1 > ausT)? aus1 : ausT;
//console.log(" ON random   box:", ein1, d, " TTT:", einT, ausT)

			rect = $svg.rect(
				ein1, pH - .6*em, d, Options.textHeight)
				.attr("class", "rect")
				.attr("id", jobName + "_Ron")
				.attr("fill", colors.ondelta)
				.attr("title", '~' + JOB.ON.randomSign + JOB.ON.randomTime)
				.attr("fill-opacity",0.5)
				.appendTo(group);
		}


		var rCircle = Options.textHeight/2
		if ((!!JOB.ON && !!JOB.ON.fTime) && !JOB.OFF) {

			ein1 = (ein0 -s + einDelta)*H1 + offset;
			einT = ein1
			ausT = (ein1 > ausT)? ein1 : ausT;
//console.log(" ON    circle:", ein1, " TTT:", einT, ausT)

			circle = $svg.circle(
				ein1, pH + rCircle, rCircle)
				.attr("class", "circle")
				.attr("id", jobName + "_On")
				.attr("fill", colors.onoff)
				.attr("title", (jobText))
				.appendTo(group);
		}


		if ((!!JOB.OFF && JOB.OFF.fTime) && !JOB.ON) {
			aus1 = (aus0 -s  + einRandom + ausDelta)*H1 + offset;

			ausT = aus1 > ausT? aus1 : ausT;
			einT = ausT
//console.log(" ON    circle:", ein1, " TTT:", einT, ausT)

			circle = $svg.circle(
				aus1, pH + rCircle, rCircle
			)
				.attr("class", "circle")
				.attr("id", jobName+"_Off")
				.attr("fill", "black")
				.attr("title", (jobText))
				.appendTo(group);
		}


		// ----   OFF random box _______________
		if (!!JOB.OFF && (JOB.OFF.fRandomTime != 0)) {
			aus1 = (aus0 -s  + einRandom + ausDelta)*H1 + offset;
			d = ausRandom*H1;
			if (d < 0) {
				aus1 = aus1 +d;
				d = -d 
			}
			ausT = (aus1 + d) > ausT? (aus1 +d) : ausT;
//	console.log(" OFF random box:", aus1, d, " TTT:", einT, ausT);

			rect = $svg.rect(
				aus1, pH - .6*em, d, Options.textHeight
			)
				.attr("class", "rect")
				.attr("id", jobName + "_Roff")
				.attr("fill", colors.offdelta)   // "green")
				.attr("fill-opacity",0.5)
				.attr("title", '~' + JOB.OFF.randomSign + JOB.OFF.randomTime)
				.appendTo(group);
		}


		// ----  TTT  ON/OFF __________________________
		if (Options.legend != 0) {
			var aMode = (Options.legend == 2) ? "start" : "end" 
// console.log("  TTT:", Options.legend ," einT:", einT, " ausT:", ausT)

			if (Options.legend == 1){
				x = ausT + 10;
				aMode = 'start';
			}
			if (Options.legend == 2){
				x = einT - 10;
				aMode = 'end';
			}
			$svg.text(jobName+"_X",
				x, pH + 1.5*Options.textHeight,
				jobText,
				{
					fill: colors.legend,
					"font-size": .9*Options.textHeight,
					"text-anchor": aMode,
					'style':"cursor:pointer"
				})
				.appendTo(group);
		}

	}
	// ____________________ Rendering


	Timeline.prototype.scheduleSet = function(jobs){
	// "Kueche;on,09:09;off,10:54,-:20:00"
	if(info) console.info(" --------------- scheduleSet ------------------- :", jobs)

		var ON, OFF, err, mode;
		var cMode ="";
		var deltaTime, deltaSign, fDeltaTime;
		var randomTime, randomSign, fRandomTime;

		var allJobs = stripAll(jobs)

		if ((allJobs.search(";on,") == -1) && (allJobs.search(";off,") == -1)) {
				return ({'ERR': "piSchedule.noState # ERROR: no on/off"})
		}

		var jobDetails = "";
		var xTime =  null; 

		var allJobs = allJobs.split(";")
		var device = allJobs[0];

		for (var n =1; n < allJobs.length; n++) {
			jobDetails = jobDetails + allJobs[n] + ";"


			if (allJobs[n].search('on,') > -1) {
				ON = getJobDetails(allJobs[n]);
//	if(info) console.info("  scheduleSet job  ON :", ON)
			}
			if (allJobs[n].search('off,') > -1) {
				OFF = getJobDetails(allJobs[n]);
//	if(info) console.info("  scheduleSet job  OFF:", OFF)
			}
		}


		function getJobDetails(jobString) {
			xJOB = {}
			xJOB.job = jobString;
			xJOB.fTime = 0
			xJOB.fRandomTime = 0;
			xJOB.fDeltaTime = 0;
			
			var jobE = jobString.split(",");

			var nSwitch;

			for (var m in jobE) {
				nSwitch = jobE[m];

//	if(info) console.info("  getJobDetails ", m, nSwitch)
				if (nSwitch == 'on' || nSwitch == "off" || nSwitch == "time") {
					cMode = nSwitch;
				}
				// --- use deltaTime
				//  '+' add or '-' subtract time value
				//  '~' add or '~-' subtract 'random' time value
				else if (nSwitch[0] == '+' || nSwitch[0] == "-" 
					|| nSwitch[0] == "~" ){

					delta = nSwitch;
					if (delta[0] == "~") {  //#  random time 
						xJOB.randomTime = delta.substring(1);
							xJOB.randomSign = ''
						if (xJOB.randomTime[0] == '-') {
							xJOB.randomSign = '-'
							xJOB.randomTime = xJOB.randomTime.substring(1)
						}
						t = Timeline.prototype.timeSetter(xJOB.randomTime);
						xJOB.fRandomTime = (xJOB.randomSign == '-') ? -t.fTime : t.fTime;
					}

					if (delta[0] == '+' || delta[0] == "-" ) {
						xJOB.deltaSign = delta[0];
						xJOB.deltaTime = delta.substring(1);
						t = Timeline.prototype.timeSetter(xJOB.deltaTime);
						xJOB.fDeltaTime = (xJOB.deltaSign == '-') ? -t.fTime : t.fTime;
					}

				}
				else {
				//# check for absolute time not to be 24:00
					try
					{
						if (nSwitch == "24:00") nSwitch = "23:59:59"
						t = Timeline.prototype.timeSetter(nSwitch)
						xJOB.time = t.time;
						xJOB.fTime = t.fTime;
						xJOB.sun = t.sun;
					} catch (ex)
					{
						xJOB.err = " +++ piSchedule.unknownString  " + nSwitch
					}
				}
			}
			return xJOB
		}

		return ({'device':device, 'ON':ON, 'OFF':OFF, 'JOBs':jobDetails, 'ERR': err})
	}


	// Utilities
	//--------------------------------------


	Timeline.prototype.jobCorsorWorker = function (parent, text, idTxt, anchor, xT, yH, textColor, fillColor, cursorColor, instance) {

		var yT = yH - Options.textHeight

		var jCursorPos = [{ x: 0, y: 0 }];
		var cursorGroup = d3.select("#" + parent)
			.append("svg:svg")
			.attr("id", idTxt)
			.attr("class", instance)
			.attr("jobName", parent)

			.data(jCursorPos)
			.append("g")
			.attr("transform", 
				function (jCursorPos) { return "translate(" + jCursorPos.x + "," + jCursorPos.y + ")"; })
			.call(this.onDragDrop(this.dragmove, this.dropHandler, idTxt + "TXT"));

		var blueline = $svg.line(
			xT, yH + 1.5*Options.textHeight, xT, yH -Options.textHeight
		)
			.attr("stroke", cursorColor)
			.attr("stroke-width", 1)
			.attr("id","blueCursor")
		blueline.appendTo(cursorGroup);

		this.textColored (cursorGroup, text, idTxt, anchor, xT, yT, textColor, fillColor) 
	}


	Timeline.prototype.textColored = function (parent, text, idTxt, anchor, xT, yT, textColor, fillColor) {
// console.info("   textColored  parent: ",parent, " idText:", idTxt)

		var cursorType = (idTxt == "nowCursor") ? "cursor:not-allowed" : "cursor:col-resize"

		var labelText = $svg.text(idTxt + "TXT",
			xT, yT,
			text, // "hh":"mm"  or " Sunset"
			{
				fill: textColor,
				"font-size": .8*Options.textHeight,
				"text-anchor": anchor,
				"font-style": "italic",
				"class": idTxt,
				"style":cursorType
			}
		)
		labelText.appendTo(parent);

		// background for text
		var bbox = $("#" + idTxt + "TXT")[0].getBBox();
		var sRect = $svg.rect(
			// "x","y","width","height"
			bbox.x -2, bbox.y, bbox.width + 4, (+Options.textHeight + 3)
		)
			.attr("id", idTxt + "RECT")
			.attr("class", idTxt)
			.attr("fill", fillColor)
			.appendTo(parent);

		labelText.appendTo(parent);
	}


	// get the x pos for a 'hour value'
	// hvalue : number
	Timeline.prototype.getXhour = function (hvalue) {
		var hstart = this.timeSetter(Options.startTime).fTime;
		var hend = this.timeSetter(Options.endTime).fTime;
		return /*xpos */ ((hvalue - hstart) / (hend - hstart) * Options.width) + Options.PaddingX;
	};


	// convert time string "hh:mm" to array with t[hh],t[mm], t[fTime]
	// if sunrise/sunset get values and convert also
	Timeline.prototype.timeSetter = function (Xtime) {
		var t;
//	if(info) console.info("timeSetter ", Xtime)

		if (typeof Xtime == 'string') { 
			t = {}
			t.sun = ""
			if (Xtime == 'sunrise') {
				t.sun = Xtime
				Xtime = Options.sunrise;
			}

			if (Xtime == 'sunset') {
				t.sun = Xtime
				Xtime = Options.sunset;
			}
			var pieces = Xtime.split(":");

			t.hh = t.mm = t.sec = 0
			if (!pieces[0]) pieces[0] = 0
			t.hh =  pieces[0] != '' ? parseInt(pieces[0], 10) : 0;
			t.mm = parseInt(pieces[1], 10);
			t.sec = pieces[2] ? parseInt(pieces[2], 10 ) : 0;
		} else {
			t = Xtime;
		}

		t.hh = t.hh + Math.floor(t.mm/60)
		t.mm = t.mm%60
		t.time = n2(t.hh) + ":" +  n2(t.mm)

		t.fTime = t.hh + t.mm/60
		return t;
	};


	// convert date string "YYYY-MM-DD" to date object
	// return date object
	Timeline.prototype.dateSetter = function (date) {

		var cDate = new Date();

		if (typeof date == 'string') { 
			var pieces = date.split("-");

			var years  = pieces[0] ? parseInt(pieces[0], 10) : cDate.getFullYear();
			var months = pieces[1] ? (parseInt(pieces[1], 10) - 1) : cDate.getMonth();	//months are 0-based
			var days  =  pieces[2] ? parseInt(pieces[2], 10) : cDate.getDate();

			var date = new Date(years, months, days);
		}
		return date;
	};


	var $svg = {};

	$svg.group = function () {
		var element = $(svg("g"));
		return element;
	};

	$svg.line = function (x1, y1, x2, y2, options) {
		var element = $(svg("line"))
			.attr("x1", x1)
			.attr("y1", y1)
			.attr("x2", x2)
			.attr("y2", y2);
		setSvgOptions(element, options);
		return element;
	};

	$svg.circle = function (cx, cy, r, options) {
		var element = $(svg("circle"))
			.attr("cx", cx)
			.attr("cy", cy)
			.attr("r", r);
		setSvgOptions(element, options);
		return element;
	};

	$svg.rect = function (x, y, width, height, options) {
		var element = $(svg("rect"))
			.attr("x", x)
			.attr("y", y)
			.attr("width", width)
			.attr("height", height);
		setSvgOptions(element, options);
		return element;
	};

	$svg.text = function (id, x, y, text, options) {
		var element = $(svg("text"))
			.attr("id", id)
			.attr("x", x)
			.attr("y", y)
			.text(text);
		setSvgOptions(element, options);
		return element;
	};


	function svg(tagName) {
		return document.createElementNS('http://www.w3.org/2000/svg', tagName);
	}

	function setSvgOptions(element, options) {
		if (options) {
			for (var i in options) {
				element.attr(i, options[i]);
			}
		}
	}


	function n2 (val) {
			return (val < 10) ? ("0" + val) : val;
	}


	function strip(s) {
	//	if(log) console.log( "	 strip  >>", s, "<<")
		return (!s) ? "" : (s.replace(/\s+$/,"").replace(/^\s+/,""));
	}

	function stripAll (s){
	//	if(log) console.log( "	 stripAll  >>", s, "<<")
		return (!s) ? "" : (s.replace(/\s+/g,"").replace("%20", ""))    // .replace(/\s+$/,"").replace(/^\s+/,""));
	};



	// -------- Drag & Drop ---------------

	var dSource;

	Timeline.prototype.onDragDrop = function (dragHandler, dropHandler, dJob) {
		dSource = dJob

		var drag = d3.behavior.drag();
		drag.on("drag", dragHandler)
			.on("dragend", dropHandler);
		return drag;
	}

	/*
	 * Call with D&D on a device job or the jobsDeck; if on the jobsDesk it's
	 * od D&D for 'timeCursor', do nothin.  
	 * For device/job get the x-pos of the cursor and pick the cursor 
	 * type (On, Off, or random) and the data of the current device job.
	 * Finally replace the current jobs with the dropped values and draw new.
	 */
	Timeline.prototype.dropHandler = function (d) {

		var dropped = timeFromPos(this, d)
		var jobName = dropped[0]
		var jobNo = dropped[1]
		var dropTime = dropped[4] + ":" + dropped[5]

		var mode = ((dropped[2] == 'OffCursor') && (dropped[3] == "On")) ? 'Off' :  dropped[3]

		if (jobName == 'timeCursor') { return }	// was the timecursor

		var xDrop = Timeline.prototype.timeSetter(dropTime)

		var jobsPosition = getJobsString (Options.device, jobNo) 
		var currentJobs = Options.xjobs[jobsPosition]

		var actualJOB = xJOB = Timeline.prototype.scheduleSet(currentJobs);

  console.log(" actualJOB    #:", jobsPosition, actualJOB.device,
			"\n     ON  :", actualJOB.ON, 
			"\n    OFF  :", actualJOB.OFF);

	if(info) console.info(" dropHandler  #:", jobNo, jobName, mode , xDrop);

		//mode:  On, Off, Ron, Roff
		var onfTime = 0;
		if (mode == 'On') {
			xJOB.ON.time = xDrop.time
			xJOB.ON.fTime = xDrop.fTime
			onfTime = xJOB.ON.fTime
		}

		if (mode == 'Off') {
			xJOB.OFF.time = xDrop.time
			xJOB.OFF.fTime = xDrop.fTime
		}

		var onDelta = 0; var onfRandomTime = (!!xJOB.ON) ? xJOB.ON.fRandomTime : 0;
		if (mode == 'Ron') {

console.info("  Ron random:", (xJOB.ON.fTime > xDrop.fTime), (xJOB.ON.fTime ), xDrop.fTime)

			if (xJOB.ON.fTime > xDrop.fTime) {
				onDelta = -(xJOB.ON.fTime +xJOB.ON.fDeltaTime - xDrop.fTime)
				xJOB.ON.randomSign = "-"
			} else {
				var onDelta = (xDrop.fTime - xJOB.ON.fTime -xJOB.ON.fDeltaTime)
				xJOB.ON.randomSign = ""
			}
			xJOB.ON.fRandomTime = onDelta
			onfRandomTime = onDelta
			xJOB.ON.randomTime = timeHHMM(onDelta)
		}

		if (mode == 'Roff') {

console.info("  Roff random:", (xJOB.OFF.fTime + onfRandomTime + onDelta) < xDrop.fTime,
		(xJOB.OFF.fTime + onfRandomTime + onDelta), xDrop.fTime,
		"details:", " xJOB.OFF.fTime:", xJOB.OFF.fTime, " ON.fRandomTime:", onfRandomTime, " onDelta:", onDelta, " dropTime:",xDrop.fTime)

			if ((xJOB.OFF.fTime + onfRandomTime + onDelta) < xDrop.fTime) {
				var x = (xDrop.fTime - (xJOB.OFF.fTime + onfRandomTime + onDelta))
				xJOB.OFF.randomSign = ""
			} else {
				var x = -((xJOB.OFF.fTime + onfRandomTime + onDelta) - xDrop.fTime)
				xJOB.OFF.randomSign = "-"
			}
			xJOB.OFF.fRandomTime = x
			xJOB.OFF.randomTime = timeHHMM(x)
		}

	if(info) console.info("   changed JOB  ", "\n  ++ ON :", xJOB.ON, "\n  ++ OFF :", xJOB.OFF)

		var newJobs = Options.device + ";"

		var jobONtext = jobOFFtext = "";
		if (!!xJOB.ON) {
			if (!!xJOB.ON.sun) {
				jobONtext += (',' + xJOB.ON.sun);
			} else {
				jobONtext += (',' + xJOB.ON.time);
			}
			if (!!xJOB.ON.deltaTime) jobONtext += ',' + xJOB.ON.deltaSign + xJOB.ON.deltaTime
			if (!!xJOB.ON.randomTime) jobONtext += ',~' + xJOB.ON.randomSign + xJOB.ON.randomTime
		}

		if (!!xJOB.OFF) {
			if (!!xJOB.OFF.sun) {
				jobOFFtext += (',' + xJOB.OFF.sun);
			} else {
				jobOFFtext += (!!xJOB.OFF.time) ? (',' + xJOB.OFF.time) : "";
			}
			if (!!xJOB.OFF.deltaTime) jobOFFtext += ',' + xJOB.OFF.deltaSign + xJOB.OFF.deltaTime
			if (!!xJOB.OFF.randomTime) jobOFFtext += ',~' + xJOB.OFF.randomSign + xJOB.OFF.randomTime
		}

		jobText = ((jobONtext == "") ? "" : "on" + jobONtext); 
		jobText += ((jobONtext == "") ? "" : ((jobOFFtext != "") ? ";" : ""));
		jobText += ((jobOFFtext == "") ? "" : ("off" + jobOFFtext)); 

		newJobs += jobText
console.info("-------------------------\n------------------------- ", newJobs)

		if (xJOB.ERR) {
	if(log) console.error(" piSchedule Timeline ", xJOB.ERR, " job:",xJob)
			return
		}

		d3.select("#" + jobName).remove()
		var jobGroup = $("#" + jobName + "GROUP")

		Timeline.prototype.drawJob(xJOB, jobNo, jobGroup);

		// set new jobs to list 
		// --->  needs to write back to the INI File
		//       requires user ack
		Options.xjobs[jobsPosition] =  newJobs;

		jobsChangeSet (true);
	}


	/*
	 *  if jobList has changed !  ==> set "changed"
	 */
	function jobsChangeSet (mode) {
		//$("#jobListChanged")[0].textContent = mode ? "Changed!" : " "
		jobsChanged = mode;

		if (mode == false) {
			$("#savebutton")[0].setAttribute("src","/static/gsavegray.png")
		} else {
			$("#savebutton")[0].setAttribute("src","/static/gsaveblue.png")
		}

	}


	// find the 'line' in the jobs list for a given device and position
	// return  position number in 'Options.xjobs' 
	function getJobsString (currentDevice, jobNo) {

		var now = new Date();
		var jobs = Options.xjobs;

		// piSchedule job string
		var nJob = 0; var xJob; var xDevice;
		if (jobs && jobs.length >0) {
			for (var jobPosition = 0; jobPosition < jobs.length; jobPosition++) {

				xJob = stripAll(jobs[jobPosition]);
				xDevice = xJob.split(";")[0]

				if ((!xDevice) || (xDevice == "")) continue;
				if (Options.device != xDevice) continue;
				if (nJob == jobNo) break;
				nJob++
			}
		}
		return jobPosition
	}



	Timeline.prototype.dragmove = function (d) {

		d.x += d3.event.dx;
	//	d.y += d3.event.dy;		// don't move in Y direction

		d3.select(this).attr("transform", "translate(" + d.x + "," + d.y + ")");
		var moved = timeFromPos(this, d)

	}


function removeObjectFromObject (allObjects, objName){
	var newObj = {};
	for (var obj in allObjects) {
		if (obj !== objName) {
			newObj[obj] = {};
			newObj[obj] =  allObjects[obj];
		}
	}
	return newObj;
};


function removeObjectN (allObjects, n){
	var newObj = [];
	var m = 0;
	for (var obj in allObjects) {
		if (+obj !== +n) {
			newObj[m] = {};
			newObj[m] =  allObjects[obj];
			m++;
		}
	}
	return newObj;
};


// Options.xjobs = addObjectN (Options.xjobs, jobsPosition, job);
function addObjectN (allObjects, n, addObj){

console.log("   addObj ", allObjects)
	var newObj = [];
	var m = 0;
	for (var obj in allObjects) {
		if (+obj !== +n) {
			newObj[m] = {};
			newObj[m] =  allObjects[obj];
			m++;
		} else {
			newObj[m] = {};
			newObj[m] =  addObj;
			m++;
			newObj[m] =  allObjects[obj];
			m++;
		}
	}
console.log("  after add ", newObj)
	return newObj;
};


	function timeHHMM(x) {
		x = Math.abs(x)
		h = Math.floor(x)
		var m = Math.round((x -h)%60*60)
		var y =  n2(h) + ":" +n2(m)
		return n2(h) + ":" +n2(m)
	}

	function timeFromPos(xThis, d) {

		var jobName = xThis.parentNode.attributes.jobName.value
		var jobNo = (jobName != "timeCursor") ? $("#" + jobName).attr('jobNo') : -1

		var isClass = xThis.parentNode.className.animVal

		var thisSvg = d3.select(xThis)[0][0].viewportElement.id

		var timeX = d3.select("#" + thisSvg + "TXT")[0]
//	if(info) console.info("  job:", jobName, "  thisSvg:", thisSvg, "  time: ", timeX[0].textContent)

		var hstart = (Options.startTime).hh;
		var hend = (Options.endTime).hh;

		var x = timeX[0].x.animVal[0].value + d.x
		x = (x - Options.PaddingX)
		var xTime = x/Options.width * (hend-hstart) + hstart

		var hh = n2(Math.floor(xTime))
		var min = n2(Math.floor(Math.floor((xTime - hh)*100)*.6))

		timeX[0].textContent = hh + ":" + min

		jobCursorLast = (thisSvg != 'timeCursor') ? true : false
		return [jobName, jobNo, thisSvg, isClass, hh, min]
	}


})(jQuery);

