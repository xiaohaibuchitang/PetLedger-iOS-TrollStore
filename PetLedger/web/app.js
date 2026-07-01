const budget = 3000;

let mode = "personal";
let selectedCategory = {
  name: "餐饮",
  icon: "ph-fork-knife",
};

const categoryMeta = {
  餐饮: {
    icon: "ph-fork-knife",
    bg: "#fff0d8",
    color: "#e19a21",
  },
  交通: {
    icon: "ph-train",
    bg: "#e7f1ff",
    color: "#2778bd",
  },
  学习: {
    icon: "ph-book-open",
    bg: "#e9f4e4",
    color: "#3f8f55",
  },
  日用: {
    icon: "ph-shopping-bag",
    bg: "#f4edff",
    color: "#7c61bd",
  },
};

const transactions = [
  { name: "早餐", category: "餐饮", time: "今天 08:32", amount: 18 },
  { name: "地铁", category: "交通", time: "今天 07:58", amount: 4 },
  { name: "咖啡", category: "餐饮", time: "今天 10:21", amount: 16 },
  { name: "学习用品", category: "学习", time: "今天 13:20", amount: 30 },
  { name: "晚餐", category: "餐饮", time: "昨天 18:42", amount: 46.5 },
  { name: "便利店", category: "日用", time: "周一 19:10", amount: 23 },
];

const coupleTransactions = [
  { name: "双人早餐", category: "餐饮", time: "今天 09:04", amount: 36 },
  { name: "通勤", category: "交通", time: "今天 08:12", amount: 8 },
  { name: "周末旅行基金", category: "日用", time: "昨天 22:00", amount: 80 },
  { name: "电影票", category: "日用", time: "周日 16:30", amount: 78 },
];

const petStops = [
  { left: "41%", top: "64%", message: "一起加油，今天记得很清楚呢" },
  { left: "30%", top: "66%", message: "精灵在房间里散步，等你记下一笔。" },
  { left: "56%", top: "62%", message: "预算进度很稳，小窝也很安心。" },
  { left: "68%", top: "50%", message: "它绕着存钱罐走了一圈。" },
];

const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => Array.from(document.querySelectorAll(selector));

const formatMoney = (value) =>
  `¥${value.toLocaleString("zh-CN", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}`;

const formatSummaryMoney = (value) => `¥${Math.round(value).toLocaleString("zh-CN")}`;

function getActiveTransactions() {
  return mode === "personal" ? transactions : coupleTransactions;
}

function renderTransactions() {
  const recentTarget = $("#recentTransactions");
  const allTarget = $("#allTransactions");
  const active = getActiveTransactions();
  recentTarget.innerHTML = active.slice(0, 4).map(renderRow).join("");
  allTarget.innerHTML = active.map(renderRow).join("");
}

function renderRow(item) {
  const meta = categoryMeta[item.category] || categoryMeta["日用"];
  return `
    <button class="transaction-row" type="button">
      <span class="category-icon" style="--icon-bg:${meta.bg}; --icon-color:${meta.color}">
        <i class="ph-fill ${meta.icon}"></i>
      </span>
      <span>
        <strong>${item.name}</strong>
        <span>${item.time} · ${item.category}</span>
      </span>
      <b>${formatMoney(item.amount)}</b>
      <i class="ph ph-caret-right"></i>
    </button>
  `;
}

function updateFinance() {
  const active = getActiveTransactions();
  const todaySpend = active
    .filter((item) => item.time.startsWith("今天"))
    .reduce((sum, item) => sum + item.amount, 0);
  const baseMonth = mode === "personal" ? 1200.5 : 1680;
  const monthSpend = active.reduce((sum, item) => sum + item.amount, baseMonth);
  const remain = Math.max(budget - monthSpend, 0);
  const usedRate = Math.min((monthSpend / budget) * 100, 100);
  const remainRate = Math.max(100 - usedRate, 0);

  $("#todaySpend").textContent = formatMoney(todaySpend);
  $("#monthSpend").textContent = formatSummaryMoney(monthSpend);
  $("#remainBudget").textContent = formatSummaryMoney(remain);
  $("#remainRate").textContent = `${remainRate.toFixed(1)}%`;
  $("#budgetRate").textContent = `预算进度 ${usedRate.toFixed(1)}%`;
  $("#budgetFill").style.width = `${usedRate}%`;
  $("#budgetHeroRate").textContent = `${usedRate.toFixed(1)}%`;
  $("#budgetHeroRemain").textContent = formatMoney(remain);
  $("#ringRate").textContent = `${Math.round(usedRate)}%`;
  $(".budget-ring").style.background = `conic-gradient(var(--green) 0 ${usedRate * 3.6}deg, rgba(0, 0, 0, 0.08) ${usedRate * 3.6}deg 360deg)`;
  $("#budgetAdvice").textContent =
    mode === "personal"
      ? "餐饮预算还很稳，咖啡可以控制在每周 3 次。"
      : "共同账本保持得不错，可以把旅行基金继续自动存入。";
}

function switchScreen(name) {
  $$(".screen").forEach((screen) => {
    screen.classList.toggle("screen-active", screen.dataset.screen === name);
  });
  $$(".tab-bar button").forEach((tab) => {
    const active = tab.dataset.tab === name;
    tab.classList.toggle("tab-active", active);
    const icon = tab.querySelector("i");
    icon.classList.toggle("ph-fill", active);
    icon.classList.toggle("ph", !active);
  });
}

function setMode(nextMode) {
  mode = nextMode;
  $$(".mode-button").forEach((button) => {
    button.classList.toggle("mode-active", button.dataset.mode === mode);
  });
  const headerTitle = $(".top-header h1");
  headerTitle.textContent =
    mode === "personal" ? "早安，今天也要好好记账哦" : "早安，一起把小日子记清楚";
  renderTransactions();
  updateFinance();
}

function openSheet() {
  $("#sheetBackdrop").classList.add("visible");
  $("#addSheet").classList.add("open");
  $("#addSheet").setAttribute("aria-hidden", "false");
  setTimeout(() => $("#amountInput").focus(), 80);
}

function closeSheet() {
  $("#sheetBackdrop").classList.remove("visible");
  $("#addSheet").classList.remove("open");
  $("#addSheet").setAttribute("aria-hidden", "true");
}

function addTransaction() {
  const amount = Number($("#amountInput").value);
  const note = $("#noteInput").value.trim() || selectedCategory.name;
  if (!Number.isFinite(amount) || amount <= 0) {
    showToast("先输入一个有效金额");
    return;
  }

  const item = {
    name: note,
    category: selectedCategory.name,
    time: "今天 刚刚",
    amount,
  };

  if (mode === "personal") {
    transactions.unshift(item);
  } else {
    coupleTransactions.unshift(item);
  }

  renderTransactions();
  updateFinance();
  closeSheet();
  movePet({ left: "43%", top: "55%" }, "已记账，小离也跟着安心了一点");
  showToast("已记账，小离也跟着安心了一点");
}

function showToast(message) {
  const toast = $("#toast");
  toast.textContent = message;
  toast.classList.add("show");
  clearTimeout(showToast.timer);
  showToast.timer = setTimeout(() => toast.classList.remove("show"), 1800);
}

function movePet(target, message) {
  const pet = $("#petSpirit");
  pet.style.left = target.left;
  pet.style.top = target.top;
  $("#petBubble").textContent = message;
}

function startPetWander() {
  let index = 0;
  setInterval(() => {
    index = (index + 1) % petStops.length;
    movePet(petStops[index], petStops[index].message);
  }, 5200);
}

function bindEvents() {
  $$(".tab-bar button").forEach((button) => {
    button.addEventListener("click", () => switchScreen(button.dataset.tab));
  });

  $$("[data-screen-link]").forEach((button) => {
    button.addEventListener("click", () => switchScreen(button.dataset.screenLink));
  });

  $$(".mode-button").forEach((button) => {
    button.addEventListener("click", () => setMode(button.dataset.mode));
  });

  $$("[data-open-add]").forEach((button) => button.addEventListener("click", openSheet));
  $$("[data-close-add], #sheetBackdrop").forEach((button) => button.addEventListener("click", closeSheet));
  $("#submitExpense").addEventListener("click", addTransaction);

  $$(".category-choice").forEach((button) => {
    button.addEventListener("click", () => {
      $$(".category-choice").forEach((choice) => choice.classList.remove("choice-active"));
      button.classList.add("choice-active");
      selectedCategory = {
        name: button.dataset.category,
        icon: button.dataset.icon,
      };
      $("#noteInput").value = button.dataset.category === "餐饮" ? "早餐" : button.dataset.category;
    });
  });

  $$(".hotspot").forEach((button) => {
    button.addEventListener("click", () => {
      const rect = button.getBoundingClientRect();
      const scene = $("#petScene").getBoundingClientRect();
      const left = `${((rect.left + rect.width / 2 - scene.left) / scene.width) * 100}%`;
      const top = `${((rect.top + rect.height / 2 - scene.top) / scene.height) * 100}%`;
      movePet({ left, top }, button.dataset.petAction);
      showToast(button.dataset.petAction);
    });
  });

  $$(".swatch").forEach((button) => {
    button.addEventListener("click", () => {
      $$(".swatch").forEach((swatch) => swatch.classList.remove("active-swatch"));
      button.classList.add("active-swatch");
      showToast("毛色已切换，正式版可继续解锁更多宠物样式");
    });
  });
}

renderTransactions();
updateFinance();
bindEvents();
startPetWander();
