var head = document.getElementsByTagName("head")[0];
for (const weight of ["regular", "fill"]) {
  var link = document.createElement("link");
  link.rel = "stylesheet";
  link.type = "text/css";
  link.href = `./icons/${weight}/style.css`;
  head.appendChild(link);
}
