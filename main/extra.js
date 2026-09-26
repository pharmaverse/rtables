// Resolve the "Validation report" navbar link to the correct report for the
// documentation version currently being viewed.
//
// pkgdown builds one independent static site per package version, and this file
// is auto-included on every page of each build. It reads the version shown in
// the navbar and points the link at the newest validation report whose version
// is <= the current version. Versions older than the first available report do
// not get a link at all.
//
// To add a report for a future release, add its version to REPORTS. Order does
// not matter. Also update the static href in _pkgdown.yml, which is what readers
// with JavaScript disabled get.
(function () {
  "use strict";

  // Versions that have a validation report. Order does not matter.
  var REPORTS = ["0.6.16"];
  var REPORT_BASE =
    "https://pharmar.github.io/pharmapkgs/src/contrib/Meta/validation_report_rtables_v";

  // Parse a version string like "0.2.13" or "0.2.13.9004" into a numeric array.
  function parseVersion(v) {
    return v.split(/[.-]/).map(function (x) {
      var n = parseInt(x, 10);
      return isNaN(n) ? 0 : n;
    });
  }

  // Compare two parsed versions: returns <0, 0, or >0.
  function compareVersions(a, b) {
    var len = Math.max(a.length, b.length);
    for (var i = 0; i < len; i++) {
      var d = (a[i] || 0) - (b[i] || 0);
      if (d !== 0) return d;
    }
    return 0;
  }

  // Newest report version that is <= the current version, or null if none.
  // Takes the maximum rather than the last match, so REPORTS need not be sorted.
  function pickReport(current) {
    var cur = parseVersion(current);
    var chosen = null;
    for (var i = 0; i < REPORTS.length; i++) {
      if (compareVersions(cur, parseVersion(REPORTS[i])) < 0) continue;
      if (chosen === null || compareVersions(parseVersion(REPORTS[i]), parseVersion(chosen)) > 0) {
        chosen = REPORTS[i];
      }
    }
    return chosen;
  }

  // Read the package version from the navbar of the current page.
  function detectVersion() {
    var selectors = [
      ".navbar small",
      "small.nav-text",
      ".navbar .version",
      ".navbar-brand + small",
      "header .version"
    ];
    var re = /\d+\.\d+\.\d+(?:\.\d+)*/;
    for (var i = 0; i < selectors.length; i++) {
      var el = document.querySelector(selectors[i]);
      if (el) {
        var m = el.textContent.match(re);
        if (m) return m[0];
      }
    }
    // Fallback: scan the whole navbar/header text.
    var header = document.querySelector(".navbar") || document.querySelector("header");
    if (header) {
      var hm = header.textContent.match(re);
      if (hm) return hm[0];
    }
    return null;
  }

  // Find the "Validation report" anchor by its (case-insensitive) link text.
  // Scoped to the navbar so page content using the same wording is left alone.
  function findLink() {
    var roots = [document.querySelector(".navbar"), document.querySelector("header")];
    for (var r = 0; r < roots.length; r++) {
      if (!roots[r]) continue;
      var anchors = roots[r].querySelectorAll("a");
      for (var i = 0; i < anchors.length; i++) {
        if (anchors[i].textContent.trim().toLowerCase() === "validation report") {
          return anchors[i];
        }
      }
    }
    return null;
  }

  // Nearest ancestor <li>, or null. Stands in for Element.closest(), which the
  // rest of this file's ES5 target does not assume.
  function closestListItem(el) {
    for (var node = el; node; node = node.parentNode) {
      if (node.nodeName && node.nodeName.toLowerCase() === "li") return node;
    }
    return null;
  }

  function run() {
    var link = findLink();
    if (!link) return;

    var version = detectVersion();
    // If we cannot detect the version, leave the static fallback href in place.
    if (!version) return;

    var report = pickReport(version);
    if (report) {
      link.setAttribute("href", REPORT_BASE + report + ".html");
    } else {
      // No report for versions older than the first available one: drop the item.
      var target = closestListItem(link) || link;
      if (target.parentNode) target.parentNode.removeChild(target);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", run);
  } else {
    run();
  }
})();
