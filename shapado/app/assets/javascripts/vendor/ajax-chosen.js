(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  (function($) {
    return $.fn.ajaxChosen = function(options, itemBuilder) {
      var defaultedOptions, inputSelector, multiple, select;
      defaultedOptions = {
        minLength: 3,
        queryParameter: 'term',
        queryLimit: 10,
        data: {},
        chosenOptions: {},
        searchingText: "Searching...",
        noresultsText: "No results."
      };
      $.extend(defaultedOptions, options);
      if (defaultedOptions.success) {
        defaultedOptions.userSuppliedSuccess = defaultedOptions.success;
      }
      defaultedOptions.chosenOptions.no_results_text = defaultedOptions.searchingText;
      multiple = this.attr('multiple') != null;
      if (multiple) {
        inputSelector = ".search-field > input";
      } else {
        inputSelector = ".chzn-search > input";
      }
      select = this;
      this.chosen(defaultedOptions.chosenOptions);
      return this.next('.chzn-container').find(inputSelector).bind('keyup', function(e) {
        var search;
        if (this.previousSearch) {
          clearTimeout(this.previousSearch);
        }
        search = __bind(function() {
          var clearSearchingLabel, currentOptions, field, prevVal, val, _ref;
          val = $.trim($(this).attr('value'));
          prevVal = (_ref = $(this).data('prevVal')) != null ? _ref : '';
          $(this).data('prevVal', val);
          field = $(this);
          clearSearchingLabel = __bind(function() {
            var resultsDiv;
            if (multiple) {
              resultsDiv = field.parent().parent().siblings();
            } else {
              resultsDiv = field.parent().parent();
            }
            return resultsDiv.find('.no-results').html(defaultedOptions.noresultsText + " '" + $(this).attr('value') + "'");
          }, this);
          if (val.length < defaultedOptions.minLength || val === prevVal) {
            clearSearchingLabel();
            return false;
          }
          currentOptions = select.find('option');
          if (currentOptions.length < defaultedOptions.queryLimit && val.indexOf(prevVal) === 0 && prevVal !== '') {
            clearSearchingLabel();
            return false;
          }
          defaultedOptions.data[defaultedOptions.queryParameter] = val;
          defaultedOptions.success = function(data) {
            var currentOpt, items, keydownEvent, latestVal, newOpt, newOptions, noResult, _fn, _fn2, _i, _j, _len, _len2;
            if (!field.is(':focus')) {
              return;
            }
            items = itemBuilder(data);
            newOptions = [];
            $.each(items, function(value, text) {
              var newOpt;
              newOpt = $('<option>');
              newOpt.attr('value', value).html(text);
              return newOptions.push($(newOpt));
            });
            _fn = function(currentOpt) {
              var $currentOpt, newOption, presenceInNewOptions;
              $currentOpt = $(currentOpt);
              if ($currentOpt.attr('selected') && multiple) {
                return;
              }
              if ($currentOpt.attr('value') === '' && $currentOpt.html() === '' && !multiple) {
                return;
              }
              presenceInNewOptions = (function() {
                var _j, _len2, _results;
                _results = [];
                for (_j = 0, _len2 = newOptions.length; _j < _len2; _j++) {
                  newOption = newOptions[_j];
                  if (newOption.attr('value') === $currentOpt.attr('value')) {
                    _results.push(newOption);
                  }
                }
                return _results;
              })();
              if (presenceInNewOptions.length === 0) {
                return $currentOpt.remove();
              }
            };
            for (_i = 0, _len = currentOptions.length; _i < _len; _i++) {
              currentOpt = currentOptions[_i];
              _fn(currentOpt);
            }
            currentOptions = select.find('option');
            _fn2 = function(newOpt) {
              var currentOption, presenceInCurrentOptions, _fn3, _k, _len3;
              presenceInCurrentOptions = false;
              _fn3 = function(currentOption) {
                if ($(currentOption).attr('value') === newOpt.attr('value')) {
                  return presenceInCurrentOptions = true;
                }
              };
              for (_k = 0, _len3 = currentOptions.length; _k < _len3; _k++) {
                currentOption = currentOptions[_k];
                _fn3(currentOption);
              }
              if (!presenceInCurrentOptions) {
                return select.append(newOpt);
              }
            };
            for (_j = 0, _len2 = newOptions.length; _j < _len2; _j++) {
              newOpt = newOptions[_j];
              _fn2(newOpt);
            }
            latestVal = field.val();
            if ($.isEmptyObject(data)) {
              noResult = $('<option>');
              noResult.addClass('no-results');
              noResult.html(defaultedOptions.noresultsText + " '" + latestVal + "'").attr('value', '');
              select.append(noResult);
            } else {
              select.change();
            }
            select.trigger("liszt:updated");
            $('.no-results').removeClass('active-result');
            field.val(latestVal);
            if (!$.isEmptyObject(data)) {
              keydownEvent = $.Event('keydown');
              keydownEvent.which = 40;
              field.trigger(keydownEvent);
            }
            if (defaultedOptions.userSuppliedSuccess) {
              return defaultedOptions.userSuppliedSuccess(data);
            }
          };
          return $.ajax(defaultedOptions);
        }, this);
        return this.previousSearch = setTimeout(search, 100);
      });
    };
  })(jQuery);
}).call(this);