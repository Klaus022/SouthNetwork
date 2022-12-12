class MessageListener {
	eventHandlers = {};

	constructor() {
		window.addEventListener("message", (event) => {
			if (!event || !event.data || !event.data.action) return;

			const func = this.eventHandlers[event.data.action];
			if (func) func(event.data);
		});
	}

	addHandler(actionName, func) {
		this.eventHandlers[actionName] = async function (data) {
			func(data);
		};
	}
}

const messageListener = new MessageListener();

messageListener.addHandler("WaitForRace", (data) => {
	$("body").css("background-color", "rgba(58, 58, 58, 0.5)");
	$("#countdown").css("display", "flex");
	$("#countdown").removeClass("finish");
	var timeLeft = data.timeLeft - 1;
	$("#countdown").html(
		"<span>Corrida iniciando em:</span><h1>" + data.timeLeft + "</h1>"
	);
	var downloadTimer = setInterval(function () {
		$("#countdown").html(
			"<span>Corrida iniciando em:</span><h1>" + timeLeft + "</h1>"
		);
		timeLeft -= 1;
		if (timeLeft <= -1) {
			clearInterval(downloadTimer);
			$("#countdown").addClass("finish");
			$("#countdown").html("JÁ");
			setTimeout(() => {
				$("body").css("background-color", "rgba(58, 58, 58, 0.0)");
				$("#countdown").css("display", "none");
				$("#infos").css("display", "flex");
			}, 1000);
		}
	}, 1000);
});

messageListener.addHandler("cancelRace", (data) => {
	$("body").css("background-color", "rgba(58, 58, 58, 0.0)");
	$("#countdown").css("display", "none");
	$("#infos").css("display", "none");
});

messageListener.addHandler("hideRaceInfo", (data) => {
	$("#infos").css("display", "none");
});

messageListener.addHandler("updateInfos", (data) => {
	$("#infos").html(`
        <h1>${data.currentPos}°<sub>/ ${data.lastPos}</sub></h1>
        <span style="color: ${
			data.showRed ? "red" : "white"
		};"><i class="fas fa-clock" style="color: ${
		data.showRed ? "red" : "white"
	};"></i> ${data.time}</span>
        <span><i class="fas fa-map-marker-alt"></i> ${
			data.currentCheckpoint - 1
		}/${data.lastCheckpoint}</span>
        <span><i class="fas fa-flag-checkered"></i> ${data.currentLap}/${
		data.lastLap
	}</span>
    `);
});

messageListener.addHandler("hideRaceStats", (data) => {
	$("#esc-text").css("display", "none");
	$("#race-stats").css("display", "none");
});

messageListener.addHandler("showRaceStats", (data) => {
	let stats = "";

	for (let i = 0; i < data.stats.length; i++) {
		let v = data.stats[i];
		stats += `
            <div class="item">
                <div class="row">
                    <i class="fas fa-user"></i>
                    <div class="info">
                        <small>Nome</small>
                        <span>${v.name}</span>
                    </div>
                </div>
                <div class="row">
                    <i class="fas fa-car"></i>
                    <div class="info">
                        <small>carro</small>
                        <span>${v.veh}</span>
                    </div>
                </div>
                <div class="row">
                    <i class="fas fa-clock"></i>
                    <div class="info">
                        <small>Tempo</small>
                        <span>${v.time}</span>
                    </div>
                </div>
            </div>
        `;
	}

	$("#esc-text").css("display", "flex");
	$("#race-stats").css("display", "flex");
	$("#race-stats").html(`
        <h1>corrida <b>finalizada</b></h1>
        <div class="win">
            <small>você ficou em</small>
            <strong>${data.position}° lugar</strong>
            <img src="src/img/medal.png" />
        </div>

        <section>
            ${stats}
        </section>

    `);
});

let currentText = 0;
let races = [];

function updateRank() {
    let u_id = parseInt(document.querySelector('#id-input').value) || false
	fetch(`https://${GetParentResourceName()}/getRaceRows`, {
		method: "POST",
		headers: {
			"Content-Type": "application/json; charset=UTF-8",
		},
		body: JSON.stringify({race: currentText == races.length - 1 ? 'global' : currentText + 1, u_id}),
    }).then(resp => resp.json().then(data => {
        let tbody = "";
        data.rows.map((v, k) => {
            tbody += `
            <tr>
                <td>${u_id ? v.position : k + 1}</td>
                <td>${v.name}</td>
                <td>${v.time}</td>
                <td>${v.wins || '-'}</td>
                <td>${v.defeats || '-'}</td>
                <td>${v.vehicle}</td>
            </tr>
            `;
        });
        $("#rank-tbody").html(tbody);
    }))
}

function nextState(element) {
	currentText += 1;
	if (currentText == races.length) currentText = 0;
    updateRank()
	$(".result").html(races[currentText].name);
}

function prevState(element) {
    currentText -= 1;
    if (currentText < 0) currentText = races.length - 1;
    updateRank()
	$(".result").html(races[currentText].name);
}

messageListener.addHandler("openRank", (data) => {
	races = data.races;
	races.push({ name: "Global" });
	currentText = races.length - 1;
	let tbody = "";
	data.rows.map((v, k) => {
		tbody += `
        <tr>
            <td>${k + 1}</td>
            <td>${v.name}</td>
            <td>${v.time}</td>
            <td>${v.wins}</td>
            <td>${v.defeats}</td>
            <td>${v.vehicle}</td>
        </tr>
        `;
	});

    document.querySelector('#race-results header input').style.display = 'flex'
    document.querySelector('#race-results header div').style.display = 'flex'
    document.querySelector('#race-results header').style.justifyContent = 'space-between'
	$(".result").html("Global");
	$("#rank-tbody").html(tbody);
	$("#race-results").css("display", "flex");
	$("body").css("background-color", "rgba(58, 58, 58, 0.5)");
});

messageListener.addHandler("openRank2", (data) => {
	let tbody = "";
	data.rows.map((v, k) => {
		tbody += `
        <tr>
            <td>${k + 1}</td>
            <td>${v.name}</td>
            <td>${v.time}</td>
            <td>${v.wins}</td>
            <td>${v.defeats}</td>
            <td>${v.vehicle}</td>
        </tr>
        `;
	});
    document.querySelector('#race-results header input').style.display = 'none'
    document.querySelector('#race-results header div').style.display = 'none'
    document.querySelector('#race-results header').style.justifyContent = 'center'
	$(".result").html("Global");
	$("#rank-tbody").html(tbody);
	$("#race-results").css("display", "flex");
	$("body").css("background-color", "rgba(58, 58, 58, 0.5)");
});

document.querySelector('#id-input').onkeydown = (e) => {
    if (e.key == 'Enter') {
        updateRank()
    }
}

document.onkeydown = (e) => {
	if (e.key == "Escape") {
		$("#race-results").css("display", "none");
		$("body").css("background-color", "transparent");
		fetch(`https://${GetParentResourceName()}/close`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json; charset=UTF-8",
			},
			body: JSON.stringify({}),
		});
	}
};
