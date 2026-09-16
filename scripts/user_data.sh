#!/bin/bash
# Bootstrap script for Amazon Linux 2023
# Installs Nginx, installs the CloudWatch agent, and deploys the static site.
set -euxo pipefail

# --- Install and start Nginx ---
dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx

# --- Deploy the static site ---
# In production you'd pull these from the S3 bucket (aws s3 cp s3://<bucket>/site/ /usr/share/nginx/html/ --recursive)
# using the instance's IAM role. For this capstone, the files are written inline so the
# page is live immediately on first boot.

cat > /usr/share/nginx/html/index.html << 'HTML_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Signal Station — Static Hosting on AWS</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>

  <header class="masthead">
    <div class="wrap">
      <span class="mark">SIGNAL STATION</span>
      <nav>
        <a href="#stack">The Stack</a>
        <a href="#route">Traffic Route</a>
        <a href="#status">Status</a>
      </nav>
    </div>
  </header>

  <main>
    <section class="hero">
      <div class="wrap">
        <p class="kicker">A page served from inside a private cloud</p>
        <h1>This page reached you through a custom VPC, a public subnet, and one small EC2 instance running Nginx.</h1>
        <p class="lede">No load balancer, no managed platform — just a hand-built network, a locked-down security group, and a web server doing exactly what it was told.</p>
        <div class="hero-meta">
          <div class="meta-item">
            <span class="num">10.0.0.0/16</span>
            <span class="label">VPC CIDR block</span>
          </div>
          <div class="meta-item">
            <span class="num">2</span>
            <span class="label">Public subnets, two AZs</span>
          </div>
          <div class="meta-item">
            <span class="num">80</span>
            <span class="label">Only port open to the world</span>
          </div>
        </div>
      </div>
    </section>

    <section class="route" id="route">
      <div class="wrap">
        <h2>How a request finds this page</h2>
        <ol class="path">
          <li>
            <span class="step-num">1</span>
            <div>
              <h3>Browser → Internet Gateway</h3>
              <p>Your request enters the VPC through the attached Internet Gateway, the only door between this network and the public internet.</p>
            </div>
          </li>
          <li>
            <span class="step-num">2</span>
            <div>
              <h3>Route table → public subnet</h3>
              <p>A route for 0.0.0.0/0 points at the gateway, so the public subnet holding this instance knows how to answer.</p>
            </div>
          </li>
          <li>
            <span class="step-num">3</span>
            <div>
              <h3>Security group → Nginx</h3>
              <p>The security group allows inbound HTTP from anywhere and SSH from one address. Nginx answers on port 80 and hands back this file.</p>
            </div>
          </li>
        </ol>
      </div>
    </section>

    <section class="stack" id="stack">
      <div class="wrap">
        <h2>What's underneath</h2>
        <div class="stack-grid">
          <div class="stack-card">
            <h3>Network</h3>
            <p>A custom VPC with two public subnets across separate availability zones, an Internet Gateway, and a route table shared between them.</p>
          </div>
          <div class="stack-card">
            <h3>Identity</h3>
            <p>An IAM role attached to the instance grants read-only S3 access and CloudWatch agent permissions — nothing more than the box needs.</p>
          </div>
          <div class="stack-card">
            <h3>Storage</h3>
            <p>A private, versioned S3 bucket holds backups and assets, reachable by the instance role but closed to the public.</p>
          </div>
          <div class="stack-card">
            <h3>Watching</h3>
            <p>CloudWatch tracks CPU utilization and status checks; an SNS topic emails an alert the moment usage crosses the line.</p>
          </div>
        </div>
      </div>
    </section>

    <section class="status" id="status">
      <div class="wrap">
        <h2>Status</h2>
        <p class="status-line"><span class="dot"></span> Web server online &mdash; served from a public subnet</p>
        <p class="status-sub">Deployed as part of an AWS static hosting capstone project.</p>
      </div>
    </section>
  </main>

  <footer>
    <div class="wrap">
      <p>Built on Amazon VPC, EC2, S3, IAM, CloudWatch, and SNS.</p>
    </div>
  </footer>

</body>
</html>

HTML_EOF

cat > /usr/share/nginx/html/style.css << 'CSS_EOF'
:root {
  --ink: #16211b;
  --paper: #eef1ea;
  --line: #b9c3b2;
  --signal: #3c6e47;
  --signal-dim: #7a9c82;
  --amber: #c98a2c;
  --mono: "IBM Plex Mono", "SFMono-Regular", Consolas, monospace;
  --serif: "Source Serif 4", "Iowan Old Style", Georgia, serif;
}

* { box-sizing: border-box; }

html { scroll-behavior: smooth; }

body {
  margin: 0;
  background: var(--paper);
  color: var(--ink);
  font-family: var(--serif);
  line-height: 1.55;
}

.wrap {
  max-width: 1040px;
  margin: 0 auto;
  padding: 0 28px;
}

a { color: inherit; }

/* Masthead */

.masthead {
  border-bottom: 1px solid var(--line);
  padding: 22px 0;
}

.masthead .wrap {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 14px;
}

.mark {
  font-family: var(--mono);
  font-size: 0.9rem;
  letter-spacing: 0.06em;
}

.masthead nav a {
  font-family: var(--mono);
  font-size: 0.85rem;
  text-decoration: none;
  margin-left: 22px;
  border-bottom: 1px solid transparent;
  padding-bottom: 2px;
}

.masthead nav a:hover { border-bottom-color: var(--signal); }

/* Hero */

.hero {
  padding: 72px 0 56px;
  border-bottom: 1px solid var(--line);
}

.kicker {
  font-family: var(--mono);
  font-size: 0.85rem;
  color: var(--signal);
  margin: 0 0 18px;
}

.hero h1 {
  font-size: clamp(1.8rem, 3.4vw, 2.7rem);
  font-weight: 500;
  line-height: 1.25;
  max-width: 18ch;
  margin: 0 0 20px;
}

.lede {
  max-width: 56ch;
  font-size: 1.08rem;
  color: #3c463f;
  margin: 0 0 44px;
}

.hero-meta {
  display: flex;
  gap: 44px;
  flex-wrap: wrap;
  border-top: 1px solid var(--line);
  padding-top: 24px;
}

.meta-item { display: flex; flex-direction: column; gap: 4px; }

.meta-item .num {
  font-family: var(--mono);
  font-size: 1.4rem;
  color: var(--ink);
}

.meta-item .label {
  font-family: var(--mono);
  font-size: 0.78rem;
  color: #62705f;
}

/* Route / numbered path — genuinely sequential, so numbering earns its place */

.route { padding: 64px 0; border-bottom: 1px solid var(--line); }

.route h2, .stack h2, .status h2 {
  font-size: 1.5rem;
  font-weight: 500;
  margin: 0 0 36px;
}

.path {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 28px;
}

.path li {
  display: grid;
  grid-template-columns: 40px 1fr;
  gap: 18px;
  align-items: start;
}

.step-num {
  font-family: var(--mono);
  font-size: 0.85rem;
  color: var(--signal);
  border: 1px solid var(--signal-dim);
  width: 34px;
  height: 34px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.path h3 {
  margin: 0 0 6px;
  font-size: 1.05rem;
  font-weight: 600;
}

.path p { margin: 0; color: #3c463f; max-width: 58ch; }

/* Stack grid */

.stack { padding: 64px 0; border-bottom: 1px solid var(--line); }

.stack-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1px;
  background: var(--line);
  border: 1px solid var(--line);
}

.stack-card {
  background: var(--paper);
  padding: 26px 28px;
}

.stack-card h3 {
  margin: 0 0 10px;
  font-family: var(--mono);
  font-size: 0.95rem;
  color: var(--signal);
}

.stack-card p { margin: 0; color: #3c463f; }

/* Status */

.status { padding: 56px 0; }

.status-line {
  font-family: var(--mono);
  font-size: 1rem;
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 0 0 8px;
}

.dot {
  width: 9px;
  height: 9px;
  border-radius: 50%;
  background: var(--signal);
  box-shadow: 0 0 0 3px rgba(60, 110, 71, 0.18);
}

.status-sub { color: #62705f; margin: 0; }

footer {
  border-top: 1px solid var(--line);
  padding: 26px 0 40px;
  font-family: var(--mono);
  font-size: 0.8rem;
  color: #62705f;
}

@media (max-width: 640px) {
  .stack-grid { grid-template-columns: 1fr; }
  .hero { padding: 52px 0 40px; }
}

CSS_EOF

chown -R nginx:nginx /usr/share/nginx/html
systemctl restart nginx

# --- Install Amazon CloudWatch Agent (for CPU/memory/disk metrics beyond the default) ---
dnf install -y amazon-cloudwatch-agent

# Minimal CloudWatch agent config: collect CPU and memory at the default namespace
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CW_EOF'
{
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_active"],
        "totalcpu": true
      },
      "mem": {
        "measurement": ["mem_used_percent"]
      }
    }
  }
}
CW_EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
