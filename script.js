// 모바일 메뉴
document.getElementById("menuBtn").addEventListener("click", () => {
  document.getElementById("navLinks").classList.toggle("open");
});

// 숫자 카운트 애니메이션
document.querySelectorAll("[data-count]").forEach((el) => {
  const target = +el.dataset.count;
  const start = performance.now();
  const step = (now) => {
    const p = Math.min((now - start) / 1600, 1);
    const v = Math.floor(target * (1 - Math.pow(1 - p, 3)));
    el.textContent = v >= 1000000 ? (v / 1000000).toFixed(1) + "M+" : v.toLocaleString();
    if (p < 1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
});

// 코드 타이핑 효과
const lines = [
  ['cm', '-- Nebula 데모 스크립트'],
  ['', '<span class="kw">local</span> greeting = <span class="str">"Hello, Nebula!"</span>'],
  ['', '<span class="kw">local</span> count = <span class="num">0</span>'],
  ['', ''],
  ['', '<span class="kw">for</span> i = <span class="num">1</span>, <span class="num">5</span> <span class="kw">do</span>'],
  ['', '    count = count + i'],
  ['', '<span class="kw">end</span>'],
  ['', ''],
  ['', '<span class="fn">print</span>(greeting)'],
  ['', '<span class="fn">print</span>(<span class="str">"Sum: "</span> .. count)'],
];
const codeEl = document.getElementById("code");
let i = 0;
function typeLine() {
  if (i >= lines.length) {
    codeEl.innerHTML += '<span class="ln">' + (i + 1) + '</span><span class="cursor">&nbsp;</span>';
    return;
  }
  const [cls, html] = lines[i];
  const body = cls ? `<span class="${cls}">${html}</span>` : html;
  codeEl.innerHTML += `<span class="ln">${i + 1}</span>${body}\n`;
  i++;
  setTimeout(typeLine, 140);
}
typeLine();

// 툴바 (데모 동작)
const con = document.getElementById("console");
document.getElementById("runBtn").addEventListener("click", () => {
  con.textContent = "> Hello, Nebula!  > Sum: 15";
});
document.getElementById("clearBtn").addEventListener("click", () => {
  con.textContent = "Cleared.";
});

// 토스트
const toast = document.getElementById("toast");
function showToast(msg) {
  toast.textContent = msg;
  toast.classList.add("show");
  setTimeout(() => toast.classList.remove("show"), 2500);
}
document.getElementById("dlBtn").addEventListener("click", (e) => {
  e.preventDefault();
  showToast("데모 사이트입니다 — 실제 다운로드 파일은 없습니다.");
});
