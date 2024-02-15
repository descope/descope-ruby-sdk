var __defProp = Object.defineProperty;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __esm = (fn, res) => function __init() {
  return fn && (res = (0, fn[__getOwnPropNames(fn)[0]])(fn = 0)), res;
};
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};

// node_modules/web-vitals/dist/web-vitals.js
var web_vitals_exports = {};
__export(web_vitals_exports, {
  getCLS: () => h,
  getFCP: () => d,
  getFID: () => L,
  getLCP: () => F,
  getTTFB: () => P
});
var e, t, n, i, r, a, o, u, c, f, s, m, v, d, p, l, h, T, y, g, E, S, w, L, b, F, P;
var init_web_vitals = __esm({
  "node_modules/web-vitals/dist/web-vitals.js"() {
    r = function(e2, t2) {
      return { name: e2, value: void 0 === t2 ? -1 : t2, delta: 0, entries: [], id: "v2-".concat(Date.now(), "-").concat(Math.floor(8999999999999 * Math.random()) + 1e12) };
    };
    a = function(e2, t2) {
      try {
        if (PerformanceObserver.supportedEntryTypes.includes(e2)) {
          if ("first-input" === e2 && !("PerformanceEventTiming" in self))
            return;
          var n2 = new PerformanceObserver(function(e3) {
            return e3.getEntries().map(t2);
          });
          return n2.observe({ type: e2, buffered: true }), n2;
        }
      } catch (e3) {
      }
    };
    o = function(e2, t2) {
      var n2 = function n3(i2) {
        "pagehide" !== i2.type && "hidden" !== document.visibilityState || (e2(i2), t2 && (removeEventListener("visibilitychange", n3, true), removeEventListener("pagehide", n3, true)));
      };
      addEventListener("visibilitychange", n2, true), addEventListener("pagehide", n2, true);
    };
    u = function(e2) {
      addEventListener("pageshow", function(t2) {
        t2.persisted && e2(t2);
      }, true);
    };
    c = function(e2, t2, n2) {
      var i2;
      return function(r2) {
        t2.value >= 0 && (r2 || n2) && (t2.delta = t2.value - (i2 || 0), (t2.delta || void 0 === i2) && (i2 = t2.value, e2(t2)));
      };
    };
    f = -1;
    s = function() {
      return "hidden" === document.visibilityState ? 0 : 1 / 0;
    };
    m = function() {
      o(function(e2) {
        var t2 = e2.timeStamp;
        f = t2;
      }, true);
    };
    v = function() {
      return f < 0 && (f = s(), m(), u(function() {
        setTimeout(function() {
          f = s(), m();
        }, 0);
      })), { get firstHiddenTime() {
        return f;
      } };
    };
    d = function(e2, t2) {
      var n2, i2 = v(), o2 = r("FCP"), f2 = function(e3) {
        "first-contentful-paint" === e3.name && (m2 && m2.disconnect(), e3.startTime < i2.firstHiddenTime && (o2.value = e3.startTime, o2.entries.push(e3), n2(true)));
      }, s2 = window.performance && performance.getEntriesByName && performance.getEntriesByName("first-contentful-paint")[0], m2 = s2 ? null : a("paint", f2);
      (s2 || m2) && (n2 = c(e2, o2, t2), s2 && f2(s2), u(function(i3) {
        o2 = r("FCP"), n2 = c(e2, o2, t2), requestAnimationFrame(function() {
          requestAnimationFrame(function() {
            o2.value = performance.now() - i3.timeStamp, n2(true);
          });
        });
      }));
    };
    p = false;
    l = -1;
    h = function(e2, t2) {
      p || (d(function(e3) {
        l = e3.value;
      }), p = true);
      var n2, i2 = function(t3) {
        l > -1 && e2(t3);
      }, f2 = r("CLS", 0), s2 = 0, m2 = [], v2 = function(e3) {
        if (!e3.hadRecentInput) {
          var t3 = m2[0], i3 = m2[m2.length - 1];
          s2 && e3.startTime - i3.startTime < 1e3 && e3.startTime - t3.startTime < 5e3 ? (s2 += e3.value, m2.push(e3)) : (s2 = e3.value, m2 = [e3]), s2 > f2.value && (f2.value = s2, f2.entries = m2, n2());
        }
      }, h2 = a("layout-shift", v2);
      h2 && (n2 = c(i2, f2, t2), o(function() {
        h2.takeRecords().map(v2), n2(true);
      }), u(function() {
        s2 = 0, l = -1, f2 = r("CLS", 0), n2 = c(i2, f2, t2);
      }));
    };
    T = { passive: true, capture: true };
    y = /* @__PURE__ */ new Date();
    g = function(i2, r2) {
      e || (e = r2, t = i2, n = /* @__PURE__ */ new Date(), w(removeEventListener), E());
    };
    E = function() {
      if (t >= 0 && t < n - y) {
        var r2 = { entryType: "first-input", name: e.type, target: e.target, cancelable: e.cancelable, startTime: e.timeStamp, processingStart: e.timeStamp + t };
        i.forEach(function(e2) {
          e2(r2);
        }), i = [];
      }
    };
    S = function(e2) {
      if (e2.cancelable) {
        var t2 = (e2.timeStamp > 1e12 ? /* @__PURE__ */ new Date() : performance.now()) - e2.timeStamp;
        "pointerdown" == e2.type ? function(e3, t3) {
          var n2 = function() {
            g(e3, t3), r2();
          }, i2 = function() {
            r2();
          }, r2 = function() {
            removeEventListener("pointerup", n2, T), removeEventListener("pointercancel", i2, T);
          };
          addEventListener("pointerup", n2, T), addEventListener("pointercancel", i2, T);
        }(t2, e2) : g(t2, e2);
      }
    };
    w = function(e2) {
      ["mousedown", "keydown", "touchstart", "pointerdown"].forEach(function(t2) {
        return e2(t2, S, T);
      });
    };
    L = function(n2, f2) {
      var s2, m2 = v(), d2 = r("FID"), p2 = function(e2) {
        e2.startTime < m2.firstHiddenTime && (d2.value = e2.processingStart - e2.startTime, d2.entries.push(e2), s2(true));
      }, l2 = a("first-input", p2);
      s2 = c(n2, d2, f2), l2 && o(function() {
        l2.takeRecords().map(p2), l2.disconnect();
      }, true), l2 && u(function() {
        var a2;
        d2 = r("FID"), s2 = c(n2, d2, f2), i = [], t = -1, e = null, w(addEventListener), a2 = p2, i.push(a2), E();
      });
    };
    b = {};
    F = function(e2, t2) {
      var n2, i2 = v(), f2 = r("LCP"), s2 = function(e3) {
        var t3 = e3.startTime;
        t3 < i2.firstHiddenTime && (f2.value = t3, f2.entries.push(e3), n2());
      }, m2 = a("largest-contentful-paint", s2);
      if (m2) {
        n2 = c(e2, f2, t2);
        var d2 = function() {
          b[f2.id] || (m2.takeRecords().map(s2), m2.disconnect(), b[f2.id] = true, n2(true));
        };
        ["keydown", "click"].forEach(function(e3) {
          addEventListener(e3, d2, { once: true, capture: true });
        }), o(d2, true), u(function(i3) {
          f2 = r("LCP"), n2 = c(e2, f2, t2), requestAnimationFrame(function() {
            requestAnimationFrame(function() {
              f2.value = performance.now() - i3.timeStamp, b[f2.id] = true, n2(true);
            });
          });
        });
      }
    };
    P = function(e2) {
      var t2, n2 = r("TTFB");
      t2 = function() {
        try {
          var t3 = performance.getEntriesByType("navigation")[0] || function() {
            var e3 = performance.timing, t4 = { entryType: "navigation", startTime: 0 };
            for (var n3 in e3)
              "navigationStart" !== n3 && "toJSON" !== n3 && (t4[n3] = Math.max(e3[n3] - e3.navigationStart, 0));
            return t4;
          }();
          if (n2.value = n2.delta = t3.responseStart, n2.value < 0 || n2.value > performance.now())
            return;
          n2.entries = [t3], e2(n2);
        } catch (e3) {
        }
      }, "complete" === document.readyState ? setTimeout(t2, 0) : addEventListener("load", function() {
        return setTimeout(t2, 0);
      });
    };
  }
});

// app/javascript/reportWebVitals.js
var reportWebVitals = (onPerfEntry) => {
  if (onPerfEntry && onPerfEntry instanceof Function) {
    Promise.resolve().then(() => (init_web_vitals(), web_vitals_exports)).then(({ getCLS, getFID, getFCP, getLCP, getTTFB }) => {
      getCLS(onPerfEntry);
      getFID(onPerfEntry);
      getFCP(onPerfEntry);
      getLCP(onPerfEntry);
      getTTFB(onPerfEntry);
    });
  }
};
var reportWebVitals_default = reportWebVitals;
export {
  reportWebVitals_default as default
};
//# sourceMappingURL=/assets/reportWebVitals.js.map
