module IsoDoc
  module Rsd
    module BaseConvert
      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def info(isoxml, out)
        @meta.security isoxml, out
        super
      end

      def executivesummary docxml, out
        f = docxml.at(ns("//executivesummary")) || return
        title_attr = { class: "IntroTitle" }
        page_break(out)
        out.div **{ class: "Section3", id: f["id"] } do |div|
          clause_name(nil, f&.at(ns("./title")), div, title_attr)
          f.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def initial_anchor_names(d)
        preface_names(d.at(ns("//executivesummary")))
        super
        sequential_asset_names(
          d.xpath(ns("//preface/abstract | //foreword | //introduction | "\
                     "//preface/clause | //acknowledgements | //executivesummary")))
      end

      def clausedelim
        ""
      end

      def section_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, level: level, xref: num }
        # subclauses are not prefixed with "Clause"
        clause.xpath(ns("./clause | ./terms | ./term | ./definitions | ./references")).
          each_with_index do |c, i|
          section_names1(c, "#{num}.#{i + 1}", level + 1)
        end
      end
    end
  end
end
