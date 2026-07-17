# Wiki Health

<div id="health-status">
  <p>Loading...</p>
</div>

<script>
(async function() {
  const el = document.getElementById('health-status');
  try {
    const res = await fetch('/status');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    const buildDate = new Date(data.build_time);
    const age = Math.floor((Date.now() - buildDate.getTime()) / 1000);
    const ageStr = age < 60 ? `${age}s` : age < 3600 ? `${Math.floor(age/60)}m` : `${Math.floor(age/3600)}h`;
    const healthy = data.file_count > 0;
    el.innerHTML = `
      <table>
        <tr><td>Status</td><td>${healthy ? 'OK' : 'DEGRADED'}</td></tr>
        <tr><td>Files</td><td>${data.file_count}</td></tr>
        <tr><td>Built</td><td>${data.build_time}</td></tr>
        <tr><td>Age</td><td>${ageStr} ago</td></tr>
      </table>
    `;
  } catch (e) {
    el.innerHTML = `<p>Unreachable: ${e.message}</p>`;
  }
})();
</script>
