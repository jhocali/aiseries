<bx:script>
hasUser         = structKeyExists( prc, "authUser" ) && !structIsEmpty( prc.authUser );
loginError      = structKeyExists( prc, "loginError" ) ? prc.loginError : "";
loginIdentifier = structKeyExists( prc, "loginIdentifier" ) ? prc.loginIdentifier : "";
dashboard       = structKeyExists( prc, "dashboard" ) ? prc.dashboard : {};
dashboardError  = structKeyExists( prc, "dashboardError" ) ? prc.dashboardError : "";
</bx:script>

<bx:output>
<style>
	:root {
		color-scheme: dark;
		font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
	}

	* {
		box-sizing: border-box;
	}

	body {
		margin: 0;
		background: ##090d10;
		color: ##f7f0e6;
		font-family: inherit;
	}

	button,
	input {
		font: inherit;
	}

	.auth-page,
	.future-page {
		position: relative;
		min-height: 100vh;
		background: ##05090c;
	}

	.auth-page {
		overflow: hidden;
	}

	.future-page {
		overflow-x: hidden;
	}

	.auth-page::before,
	.future-page::before {
		position: absolute;
		inset: 0;
		content: "";
		background-image:
			linear-gradient(180deg, rgba(5, 9, 12, 0.9) 0%, rgba(5, 9, 12, 0.48) 46%, rgba(5, 9, 12, 0.92) 100%),
			linear-gradient(90deg, rgba(5, 9, 12, 0.96) 0%, rgba(5, 9, 12, 0.74) 44%, rgba(5, 9, 12, 0.5) 100%),
			url("includes/images/login-background.png");
		background-position: center;
		background-size: cover;
	}

	.future-page::after {
		position: absolute;
		inset: 0;
		content: "";
		background-image:
			linear-gradient(rgba(143, 225, 215, 0.07) 1px, transparent 1px),
			linear-gradient(90deg, rgba(143, 225, 215, 0.055) 1px, transparent 1px),
			linear-gradient(120deg, transparent 0%, rgba(241, 145, 125, 0.1) 48%, transparent 70%),
			linear-gradient(180deg, transparent 0%, rgba(143, 225, 215, 0.08) 52%, transparent 53%);
		background-size: 70px 70px, 70px 70px, 100% 100%, 100% 6px;
		mask-image: linear-gradient(to bottom, transparent 0%, black 18%, black 82%, transparent 100%);
		animation: scanDrift 10s linear infinite;
		pointer-events: none;
	}

	.auth-shell {
		position: relative;
		display: grid;
		grid-template-columns: minmax(0, 440px) minmax(0, 1fr);
		align-items: center;
		width: min(1120px, calc(100% - 48px));
		min-height: 100vh;
		margin: 0 auto;
		padding: 40px 0;
		gap: 56px;
	}

	.login-panel {
		width: 100%;
		padding: 32px;
		border: 1px solid rgba(247, 240, 230, 0.14);
		border-radius: 8px;
		background: rgba(13, 18, 22, 0.86);
		box-shadow: 0 24px 70px rgba(0, 0, 0, 0.34);
		backdrop-filter: blur(20px);
	}

	.brand,
	.future-nav {
		display: flex;
		align-items: center;
		gap: 12px;
	}

	.brand {
		margin-bottom: 34px;
	}

	.brand-mark {
		display: grid;
		place-items: center;
		width: 42px;
		height: 42px;
		border: 1px solid rgba(126, 214, 203, 0.46);
		border-radius: 8px;
		background: ##112528;
		color: ##8fe1d7;
		font-weight: 800;
	}

	.brand-name {
		margin: 0;
		color: ##fff8ed;
		font-size: 30px;
		line-height: 1;
		font-weight: 800;
		letter-spacing: 0;
	}

	.panel-title {
		margin: 0 0 8px;
		color: ##fff8ed;
		font-size: 24px;
		line-height: 1.18;
		font-weight: 750;
		letter-spacing: 0;
	}

	.panel-copy {
		margin: 0 0 26px;
		color: ##bec9c5;
		font-size: 15px;
		line-height: 1.55;
	}

	.alert {
		margin: 0 0 20px;
		padding: 12px 14px;
		border: 1px solid rgba(241, 117, 103, 0.35);
		border-radius: 8px;
		background: rgba(83, 34, 31, 0.5);
		color: ##ffd4cf;
		font-size: 14px;
		line-height: 1.45;
	}

	.form-grid,
	.field {
		display: grid;
	}

	.form-grid {
		gap: 16px;
	}

	.field {
		gap: 8px;
	}

	.field label {
		color: ##efe8d8;
		font-size: 13px;
		font-weight: 700;
	}

	.field input[type="text"],
	.field input[type="password"] {
		width: 100%;
		min-height: 46px;
		padding: 0 13px;
		border: 1px solid rgba(247, 240, 230, 0.16);
		border-radius: 8px;
		outline: none;
		background: rgba(5, 8, 10, 0.76);
		color: ##fff8ed;
		transition: border-color 140ms ease, box-shadow 140ms ease, background 140ms ease;
	}

	.field input:focus {
		border-color: ##8fe1d7;
		background: rgba(5, 8, 10, 0.9);
		box-shadow: 0 0 0 3px rgba(126, 214, 203, 0.14);
	}

	.field input::placeholder {
		color: ##7f8a86;
	}

	.form-row {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 14px;
		margin-top: 2px;
		color: ##bec9c5;
		font-size: 13px;
	}

	.checkbox {
		display: inline-flex;
		align-items: center;
		gap: 8px;
		min-height: 28px;
	}

	.checkbox input {
		width: 16px;
		height: 16px;
		accent-color: ##8fe1d7;
	}

	.subtle-link {
		color: ##8fe1d7;
		text-decoration: none;
	}

	.subtle-link:hover {
		text-decoration: underline;
	}

	.primary-button,
	.secondary-button {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		min-height: 46px;
		border-radius: 8px;
		cursor: pointer;
		font-weight: 800;
		text-decoration: none;
	}

	.primary-button {
		width: 100%;
		margin-top: 6px;
		border: 1px solid ##8fe1d7;
		background: ##8fe1d7;
		color: ##081315;
		box-shadow: 0 12px 32px rgba(126, 214, 203, 0.18);
	}

	.primary-button:hover {
		background: ##a5e9e1;
	}

	.secondary-button {
		padding: 0 16px;
		border: 1px solid rgba(247, 240, 230, 0.18);
		background: rgba(255, 255, 255, 0.04);
		color: ##fff8ed;
	}

	.secondary-button:hover {
		background: rgba(255, 255, 255, 0.08);
	}

	.nav-actions {
		display: flex;
		align-items: center;
		gap: 10px;
		flex-wrap: wrap;
		justify-content: flex-end;
	}

	.nav-link {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		min-height: 40px;
		padding: 0 14px;
		border: 1px solid rgba(247, 240, 230, 0.12);
		border-radius: 8px;
		background: rgba(255, 255, 255, 0.035);
		color: ##d9e7e1;
		font-size: 14px;
		font-weight: 800;
		text-decoration: none;
		transition: border-color 140ms ease, background 140ms ease, color 140ms ease;
	}

	.nav-link:hover,
	.nav-link.active {
		border-color: rgba(143, 225, 215, 0.48);
		background: rgba(143, 225, 215, 0.12);
		color: ##fff8ed;
	}

	.auth-aside {
		align-self: end;
		max-width: 430px;
		margin-bottom: 12vh;
		color: rgba(255, 248, 237, 0.76);
	}

	.aside-kicker {
		margin: 0 0 12px;
		color: ##f1917d;
		font-size: 12px;
		font-weight: 800;
		text-transform: uppercase;
		letter-spacing: 0.08em;
	}

	.aside-title {
		margin: 0;
		color: ##fff8ed;
		font-size: 42px;
		line-height: 1.04;
		letter-spacing: 0;
	}

	.aside-copy {
		margin: 18px 0 0;
		color: ##d4d4cb;
		font-size: 16px;
		line-height: 1.6;
	}

	.future-shell {
		position: relative;
		z-index: 1;
		display: grid;
		grid-template-rows: auto 1fr;
		width: min(1280px, calc(100% - 48px));
		min-height: 100vh;
		margin: 0 auto;
		padding: 24px 0 30px;
	}

	.future-header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 18px;
		min-height: 66px;
		padding: 12px 14px;
		border: 1px solid rgba(247, 240, 230, 0.12);
		border-radius: 8px;
		background: rgba(5, 9, 12, 0.58);
		backdrop-filter: blur(18px);
		box-shadow: 0 18px 46px rgba(0, 0, 0, 0.24);
	}

	.dashboard-stage {
		position: relative;
		display: grid;
		gap: 22px;
		padding: 34px 0 18px;
	}

	.dashboard-intro {
		display: flex;
		align-items: end;
		justify-content: space-between;
		gap: 22px;
	}

	.dashboard-kicker {
		margin: 0 0 10px;
		color: ##f1917d;
		font-size: 12px;
		font-weight: 800;
		text-transform: uppercase;
		letter-spacing: 0;
	}

	.dashboard-title {
		margin: 0;
		color: ##fff8ed;
		font-size: clamp(36px, 6vw, 72px);
		line-height: 0.98;
		font-weight: 900;
		letter-spacing: 0;
		text-shadow:
			0 0 24px rgba(143, 225, 215, 0.2),
			0 0 52px rgba(241, 145, 125, 0.1);
	}

	.dashboard-copy {
		max-width: 620px;
		margin: 14px 0 0;
		color: ##cbd7d1;
		font-size: 16px;
		line-height: 1.55;
	}

	.dashboard-total {
		display: grid;
		gap: 6px;
		min-width: 180px;
		padding: 18px;
		border: 1px solid rgba(247, 240, 230, 0.12);
		border-radius: 8px;
		background: rgba(5, 9, 12, 0.68);
		backdrop-filter: blur(18px);
	}

	.dashboard-total span,
	.metric-label,
	.chart-kicker,
	.bar-label,
	.mini-label {
		color: ##a8b8b1;
		font-size: 12px;
		font-weight: 800;
		text-transform: uppercase;
		letter-spacing: 0;
	}

	.dashboard-total strong {
		color: ##fff8ed;
		font-size: 44px;
		line-height: 1;
	}

	.metric-grid {
		display: grid;
		grid-template-columns: repeat(3, minmax(0, 1fr));
		gap: 14px;
	}

	.metric-card {
		display: grid;
		gap: 12px;
		min-height: 142px;
		padding: 18px;
		border: 1px solid rgba(247, 240, 230, 0.12);
		border-radius: 8px;
		background:
			linear-gradient(180deg, rgba(255, 255, 255, 0.055), transparent 100%),
			rgba(5, 9, 12, 0.72);
		color: ##fff8ed;
		text-decoration: none;
		backdrop-filter: blur(18px);
		box-shadow: 0 22px 60px rgba(0, 0, 0, 0.24);
	}

	.metric-card:hover {
		border-color: rgba(143, 225, 215, 0.34);
		background:
			linear-gradient(180deg, rgba(143, 225, 215, 0.08), transparent 100%),
			rgba(5, 9, 12, 0.78);
	}

	.metric-value {
		color: ##fff8ed;
		font-size: 44px;
		line-height: 1;
		font-weight: 900;
	}

	.metric-caption {
		margin: 0;
		color: ##cbd7d1;
		font-size: 14px;
		line-height: 1.45;
	}

	.chart-grid {
		display: grid;
		grid-template-columns: minmax(0, 1.12fr) minmax(0, 0.88fr);
		gap: 16px;
	}

	.chart-panel {
		position: relative;
		padding: 20px;
		border: 1px solid rgba(247, 240, 230, 0.12);
		border-radius: 8px;
		background: rgba(5, 9, 12, 0.72);
		backdrop-filter: blur(18px);
		box-shadow: 0 24px 70px rgba(0, 0, 0, 0.25);
	}

	.chart-panel.wide {
		grid-column: 1 / -1;
	}

	.chart-header {
		display: flex;
		align-items: start;
		justify-content: space-between;
		gap: 16px;
		margin-bottom: 18px;
	}

	.chart-title {
		margin: 4px 0 0;
		color: ##fff8ed;
		font-size: 20px;
		line-height: 1.2;
		font-weight: 850;
		letter-spacing: 0;
	}

	.chart-value {
		color: ##8fe1d7;
		font-size: 28px;
		line-height: 1;
		font-weight: 900;
	}

	.bar-chart,
	.mini-bars,
	.state-bars {
		display: grid;
		gap: 14px;
	}

	.bar-row {
		display: grid;
		gap: 8px;
		color: inherit;
		text-decoration: none;
	}

	.bar-meta,
	.mini-meta {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 12px;
	}

	.bar-count,
	.mini-count {
		color: ##fff8ed;
		font-size: 14px;
		font-weight: 850;
	}

	.bar-track,
	.mini-track {
		position: relative;
		width: 100%;
		height: 18px;
		overflow: hidden;
		border: 1px solid rgba(247, 240, 230, 0.08);
		border-radius: 8px;
		background: rgba(255, 255, 255, 0.045);
	}

	.bar-fill,
	.mini-fill {
		position: absolute;
		inset: 0 auto 0 0;
		width: var(--bar-value);
		border-radius: 8px;
		background: linear-gradient(90deg, ##8fe1d7, ##b9fff5);
		box-shadow: 0 0 24px rgba(143, 225, 215, 0.24);
	}

	.bar-fill.contacts,
	.mini-fill.inactive {
		background: linear-gradient(90deg, ##f1917d, ##ffd2c8);
		box-shadow: 0 0 24px rgba(241, 145, 125, 0.18);
	}

	.mini-fill.verified,
	.mini-fill.state {
		background: linear-gradient(90deg, ##a6b9ff, ##8fe1d7);
		box-shadow: 0 0 24px rgba(166, 185, 255, 0.2);
	}

	.donut-layout {
		display: grid;
		grid-template-columns: auto minmax(0, 1fr);
		align-items: center;
		gap: 20px;
	}

	.donut {
		position: relative;
		display: grid;
		place-items: center;
		width: 156px;
		aspect-ratio: 1;
		border-radius: 50%;
		background:
			conic-gradient(##8fe1d7 var(--active-value), rgba(241, 145, 125, 0.66) 0),
			rgba(255, 255, 255, 0.045);
		box-shadow:
			inset 0 0 28px rgba(0, 0, 0, 0.34),
			0 0 42px rgba(143, 225, 215, 0.14);
	}

	.donut::before {
		position: absolute;
		inset: 18px;
		content: "";
		border-radius: 50%;
		background: rgba(5, 9, 12, 0.92);
	}

	.donut span {
		position: relative;
		color: ##fff8ed;
		font-size: 28px;
		font-weight: 900;
	}

	.empty-chart {
		margin: 0;
		padding: 18px;
		border: 1px solid rgba(247, 240, 230, 0.1);
		border-radius: 8px;
		background: rgba(255, 255, 255, 0.035);
		color: ##bac8c2;
		font-size: 14px;
		line-height: 1.5;
	}

	.future-stage {
		position: relative;
		display: grid;
		place-items: center;
		min-height: calc(100vh - 112px);
		perspective: 920px;
	}

	.future-stage::before {
		position: absolute;
		left: 50%;
		bottom: -18%;
		width: min(1080px, 112vw);
		height: 54%;
		content: "";
		background-image:
			linear-gradient(rgba(143, 225, 215, 0.2) 1px, transparent 1px),
			linear-gradient(90deg, rgba(143, 225, 215, 0.16) 1px, transparent 1px);
		background-size: 48px 48px;
		border-top: 1px solid rgba(143, 225, 215, 0.3);
		opacity: 0.6;
		transform: translateX(-50%) rotateX(68deg);
		transform-origin: top center;
		pointer-events: none;
	}

	.future-word {
		position: relative;
		z-index: 2;
		margin: 0;
		color: rgba(255, 248, 237, 0.96);
		font-size: clamp(72px, 17vw, 236px);
		line-height: 0.82;
		font-weight: 900;
		letter-spacing: 0;
		text-shadow:
			0 0 10px rgba(255, 248, 237, 0.14),
			0 0 28px rgba(143, 225, 215, 0.28),
			0 0 78px rgba(241, 145, 125, 0.18);
	}

	.future-word::before,
	.future-word::after {
		position: absolute;
		left: 0;
		content: "jojo";
		overflow: hidden;
		color: rgba(143, 225, 215, 0.42);
		pointer-events: none;
	}

	.future-word::before {
		top: -3px;
		height: 48%;
		transform: translateX(-10px);
		clip-path: inset(0 0 56% 0);
	}

	.future-word::after {
		top: 4px;
		height: 100%;
		color: rgba(241, 145, 125, 0.28);
		transform: translateX(12px);
		clip-path: inset(58% 0 0 0);
	}

	.future-frame {
		position: absolute;
		inset: 7% 3%;
		border: 1px solid rgba(143, 225, 215, 0.2);
		border-radius: 8px;
		clip-path: polygon(0 0, 34% 0, 34% 1px, 66% 1px, 66% 0, 100% 0, 100% 100%, 72% 100%, 72% calc(100% - 1px), 28% calc(100% - 1px), 28% 100%, 0 100%);
		box-shadow:
			inset 0 0 52px rgba(143, 225, 215, 0.045),
			0 0 80px rgba(143, 225, 215, 0.055);
		pointer-events: none;
	}

	.future-frame::before,
	.future-frame::after {
		position: absolute;
		top: 50%;
		width: 18%;
		height: 1px;
		content: "";
		background: linear-gradient(90deg, transparent, rgba(143, 225, 215, 0.72), transparent);
	}

	.future-frame::before {
		left: 6%;
	}

	.future-frame::after {
		right: 6%;
	}

	.future-slice {
		position: absolute;
		z-index: 1;
		width: min(760px, 76vw);
		aspect-ratio: 3 / 1;
		border: 1px solid rgba(143, 225, 215, 0.16);
		border-radius: 8px;
		background:
			linear-gradient(90deg, transparent 0%, rgba(143, 225, 215, 0.08) 48%, transparent 100%),
			linear-gradient(180deg, rgba(255, 255, 255, 0.04), transparent 58%);
		transform: translateY(12%) rotateX(58deg);
		filter: blur(0.2px);
		pointer-events: none;
	}

	@keyframes scanDrift {
		from {
			background-position: 0 0, 0 0, 0 0, 0 0;
		}

		to {
			background-position: 0 70px, 70px 0, 0 0, 0 120px;
		}
	}

	@media (prefers-reduced-motion: reduce) {
		.future-page::after {
			animation: none;
		}
	}

	@media (max-width: 780px) {
		.auth-shell {
			grid-template-columns: 1fr;
			width: min(100% - 28px, 440px);
			gap: 28px;
			padding: 24px 0;
		}

		.login-panel {
			padding: 24px;
		}

		.auth-aside {
			order: -1;
			align-self: auto;
			margin: 0;
		}

		.aside-title {
			font-size: 34px;
		}

		.future-shell {
			width: min(100% - 28px, 720px);
			padding: 20px 0;
		}

		.future-header {
			align-items: stretch;
			flex-direction: column;
		}

		.dashboard-intro,
		.chart-header,
		.donut-layout {
			display: grid;
		}

		.metric-grid,
		.chart-grid {
			grid-template-columns: 1fr;
		}

		.dashboard-total {
			min-width: 0;
		}

		.future-header .secondary-button {
			min-height: 40px;
		}

		.nav-actions,
		.nav-link,
		.future-header form,
		.future-header .secondary-button {
			width: 100%;
		}
	}
</style>

<bx:if hasUser>
	<main class="future-page">
		<div class="future-shell">
			<header class="future-header" aria-label="jojo">
				<div class="future-nav">
					<div class="brand-mark" aria-hidden="true">j</div>
					<h1 class="brand-name">Jojo AI Cool Site</h1>
				</div>

				<nav class="nav-actions" aria-label="Primary">
					<a class="nav-link active" href="/">Home</a>
					<a class="nav-link" href="/users">Users</a>
					<a class="nav-link" href="/contacts">Contacts</a>
					<form method="post" action="/logout">
						<button class="secondary-button" type="submit">Sign out</button>
					</form>
				</nav>
			</header>

			<section class="dashboard-stage" aria-labelledby="dashboard-title">
				<div class="dashboard-intro">
					<div>
						<!--- <p class="dashboard-kicker">Mongo dashboard</p> --->
						<h2 class="dashboard-title" id="dashboard-title">Database overview</h2>
						<p class="dashboard-copy">Live graphs for the users and contacts collections in jomongo.</p>
					</div>

					<div class="dashboard-total" aria-label="Total records">
						<span>Total records</span>
						<strong>#encodeForHTML( dashboard.totalRecords )#</strong>						
					</div>
				</div>

				<bx:if len( dashboardError )>
					<div class="alert" role="alert">#encodeForHTML( dashboardError )#</div>
				</bx:if>

				<div class="metric-grid" aria-label="Dashboard totals">
					<a class="metric-card" href="/users">
						<span class="metric-label">Users table</span>
						<strong class="metric-value">#encodeForHTML( dashboard.userTotal )#</strong>
						<p class="metric-caption">#encodeForHTML( dashboard.userActive )# active, #encodeForHTML( dashboard.userVerified )# email verified</p>
					</a>

					<a class="metric-card" href="/contacts">
						<span class="metric-label">Contacts table</span>
						<strong class="metric-value">#encodeForHTML( dashboard.contactTotal )#</strong>
						<p class="metric-caption">Address records available for map previews</p>
					</a>

					<div class="metric-card">
						<span class="metric-label">User health</span>
						<strong class="metric-value">#encodeForHTML( dashboard.userActivePercent )#%</strong>
						<p class="metric-caption">Active user ratio across the users table</p>
					</div>
				</div>

				<div class="chart-grid">
					<section class="chart-panel wide" aria-labelledby="table-chart-title">
						<div class="chart-header">
							<div>
								<span class="chart-kicker">Table volume</span>
								<h3 class="chart-title" id="table-chart-title">Users vs contacts</h3>
							</div>
							<strong class="chart-value">#encodeForHTML( dashboard.totalRecords )#</strong>
						</div>

						<div class="bar-chart">
							<bx:loop array="#dashboard.tableBars#" index="bar">
								<a class="bar-row" href="#encodeForHTMLAttribute( bar.href )#">
									<div class="bar-meta">
										<span class="bar-label">#encodeForHTML( bar.label )#</span>
										<strong class="bar-count">#encodeForHTML( bar.count )#</strong>
									</div>
									<div class="bar-track" aria-hidden="true">
										<span class="bar-fill #encodeForHTMLAttribute( bar.tone )#" style="--bar-value: #encodeForHTMLAttribute( bar.percent )#%;"></span>
									</div>
								</a>
							</bx:loop>
						</div>
					</section>

					<section class="chart-panel" aria-labelledby="user-chart-title">
						<div class="chart-header">
							<div>
								<span class="chart-kicker">Users</span>
								<h3 class="chart-title" id="user-chart-title">Status graph</h3>
							</div>
							<strong class="chart-value">#encodeForHTML( dashboard.userTotal )#</strong>
						</div>

						<div class="donut-layout">
							<div class="donut" style="--active-value: #encodeForHTMLAttribute( dashboard.userActivePercent )#%;" aria-label="#encodeForHTMLAttribute( dashboard.userActivePercent )# percent active">
								<span>#encodeForHTML( dashboard.userActivePercent )#%</span>
							</div>

							<div class="mini-bars">
								<bx:loop array="#dashboard.userBars#" index="bar">
									<div class="bar-row">
										<div class="mini-meta">
											<span class="mini-label">#encodeForHTML( bar.label )#</span>
											<strong class="mini-count">#encodeForHTML( bar.count )#</strong>
										</div>
										<div class="mini-track" aria-hidden="true">
											<span class="mini-fill #encodeForHTMLAttribute( bar.tone )#" style="--bar-value: #encodeForHTMLAttribute( bar.percent )#%;"></span>
										</div>
									</div>
								</bx:loop>
							</div>
						</div>
					</section>

					<section class="chart-panel" aria-labelledby="contact-chart-title">
						<div class="chart-header">
							<div>
								<span class="chart-kicker">Contacts</span>
								<h3 class="chart-title" id="contact-chart-title">Records by state</h3>
							</div>
							<strong class="chart-value">#encodeForHTML( dashboard.contactTotal )#</strong>
						</div>

						<bx:if arrayLen( dashboard.stateBars )>
							<div class="state-bars">
								<bx:loop array="#dashboard.stateBars#" index="bar">
									<div class="bar-row">
										<div class="mini-meta">
											<span class="mini-label">#encodeForHTML( bar.label )#</span>
											<strong class="mini-count">#encodeForHTML( bar.count )#</strong>
										</div>
										<div class="mini-track" aria-hidden="true">
											<span class="mini-fill #encodeForHTMLAttribute( bar.tone )#" style="--bar-value: #encodeForHTMLAttribute( bar.percent )#%;"></span>
										</div>
									</div>
								</bx:loop>
							</div>
						<bx:else>
							<p class="empty-chart">No contact records yet.</p>
						</bx:if>
					</section>
				</div>
			</section>
		</div>
	</main>
<bx:else>
	<main class="auth-page">
		<div class="auth-shell">
			<section class="login-panel" aria-labelledby="login-title">
				<div class="brand">
					<div class="brand-mark" aria-hidden="true">j</div>
					<h1 class="brand-name">jojo</h1>
				</div>

				<h2 class="panel-title" id="login-title">Sign in</h2>
				<p class="panel-copy">Use your jojo account to continue.</p>

				<bx:if len( loginError )>
					<div class="alert" role="alert">#encodeForHTML( loginError )#</div>
				</bx:if>

				<form class="form-grid" method="post" action="/login">
					<div class="field">
						<label for="identifier">Username or email</label>
						<input
							id="identifier"
							name="identifier"
							type="text"
							value="#encodeForHTMLAttribute( loginIdentifier )#"
							placeholder="jojom"
							autocomplete="username"
							required>
					</div>

					<div class="field">
						<label for="password">Password</label>
						<input
							id="password"
							name="password"
							type="password"
							placeholder="Password"
							autocomplete="current-password"
							required>
					</div>

					<div class="form-row">
						<label class="checkbox" for="remember">
							<input id="remember" name="remember" type="checkbox" value="true">
							<span>Remember me</span>
						</label>
						<a class="subtle-link" href="##">Forgot password?</a>
					</div>

					<button class="primary-button" type="submit">Sign in</button>
				</form>
			</section>

			<section class="auth-aside" aria-label="Welcome">
				<p class="aside-kicker">Secure access</p>
				<h2 class="aside-title">Welcome back.</h2>
				<p class="aside-copy">Sign in with your account and pick up where you left off.</p>
			</section>
		</div>
	</main>
</bx:if>
</bx:output>
