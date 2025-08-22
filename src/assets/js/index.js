var body = document.body;
var switcher = document.getElementsByClassName('js-toggle')[0];

function calculateTheme() {
  const localStorageTheme = localStorage.getItem("theme");
  const systemSettingDark = window.matchMedia("(prefers-color-scheme: dark)");

  if (localStorageTheme !== null) {
    return localStorageTheme;
  }

  if (systemSettingDark.matches) {
    return "dark";
  }

  return "light";
}
let currentThemeSetting = calculateTheme();

if (switcher != undefined) {
  switcher.addEventListener("click", function() {
    this.classList.toggle('js-toggle--checked');
    this.classList.add('js-toggle--focus');

    let newTheme = "light";

    //If dark mode is selected
    if (this.classList.contains('js-toggle--checked')) {
       // dark mode
      newTheme = "dark";
    }

    localStorage.setItem('theme', newTheme);
    document.querySelector("html").setAttribute("data-theme", newTheme);
  })

  if (currentThemeSetting == "dark") {
      switcher.classList.toggle('js-toggle--checked');
  }
}
document.querySelector("html").setAttribute("data-theme", currentThemeSetting);
