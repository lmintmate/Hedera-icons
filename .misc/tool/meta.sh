#!/bin/sh
if [ -f index.theme ]; then
	for _svg in $(find . -mindepth 1 -maxdepth 3 -path "*/pool/*" -wholename "*.svg"); do
#dont double meta stuff
			sed -i '/<metadata/,/<\/metadata>/d' "$_svg"
#add to end of svg
			sed -i '$ d' "$_svg"
			cat <<\EOF >>"$_svg"
  <metadata
     id="metadata9999">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title>Ivy icon theme</dc:title>
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/4.0/" />
        <dc:creator>
          <cc:Agent>
            <dc:title>Sixsixfive (sixsixfive.deviantart.com)</dc:title>
          </cc:Agent>
        </dc:creator>
        <dc:publisher>
          <cc:Agent>
            <dc:title>Sixsixfive (sixsixfive.deviantart.com)</dc:title>
          </cc:Agent>
        </dc:publisher>
        <dc:source>https://github.com/sixsixfive</dc:source>
        <dc:subject>
          <rdf:Bag>
            <rdf:li>ivy</rdf:li>
          </rdf:Bag>
        </dc:subject>
        <dc:contributor>
          <cc:Agent>
            <dc:title>ssf</dc:title>
          </cc:Agent>
        </dc:contributor>
        <dc:rights>
          <cc:Agent>
            <dc:title>Sixsixfive (sixisixfive.deviantart.com)</dc:title>
          </cc:Agent>
        </dc:rights>
        <dc:description>A simple icon theme published under CC-BY-SA_V4(http://creativecommons.org/licenses/by-sa/4.0)</dc:description>
        <dc:identifier>SSF</dc:identifier>
      </cc:Work>
    </rdf:RDF>
  </metadata>
<!--Part of the Ivy icon them published under the CC-BY-SA_V4: http://creativecommons.org/licenses/by-sa/4.0 -->
</svg>
EOF
	done
fi
