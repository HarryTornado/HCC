<?xml version="1.0" encoding="UTF-8"?>

<!--
SUMMARY OF OPERATION
* This stylesheet defines the XSLT for transforming timetable data in
  intermediate XML format to WRSA XML format.
* Pre-conditions:
  - Input XML file must be well-formed and validated.
* Note:
  - Optional element will be omitted
  - MUST USE 1999's Transform, NOT 2001's
-->
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

	<xsl:output method="xml" indent="yes"/>

	<!--
	This order must match the order defined in the param list
	generation code
	-->
	<xsl:param name="rbXml"/>
	<xsl:param name="rsXml"/>

	<xsl:variable name="rb" select="document($rbXml)"/>
	<xsl:variable name="rs" select="document($rsXml)"/>

	<xsl:template match="/">
		<Timetable xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="Timetable.xsd">
			<xsl:attribute name="Version"><xsl:value-of select="/trains/ttVersion"/></xsl:attribute>
			<xsl:attribute name="DayCode"><xsl:value-of select="/trains/dayCode"/></xsl:attribute>

			<!-- Do not have time, just use a default value -->
			<xsl:attribute name="CreationDateTime"><xsl:value-of select="/trains/creationDate"/>T00:00:00</xsl:attribute>

			<!-- Use default value defined in schema -->
			<xsl:attribute name="TimetableState">OFFLINE</xsl:attribute>

			<!-- Use default value defined in schema -->
			<xsl:attribute name="ValidationState">NOT_VALIDATED</xsl:attribute>

			<xsl:call-template name="headerInfo"/>

			<!-- DO NOT YET HAVE CIRCULAR INFO! -->

			<xsl:call-template name="allServices"/>
		</Timetable>
	</xsl:template>

	<!--
	This procedure extracts and prints the header information
	-->
	<xsl:template name="headerInfo">
		<Header>
			<TimetableFileName><xsl:value-of select="/trains/ttFileName"/></TimetableFileName>
			<BasedOnTT><xsl:value-of select="/trains/basedOnTT"/></BasedOnTT>
			<GEODataVersion/>
			<RoutesDataVersion><xsl:value-of select="$rb/routes/version"/></RoutesDataVersion>

			<!-- DO NOT YET HAVE THIS INFO! -->
			<Valid/>
			<ServicePlan/>
		</Header>
	</xsl:template>

	<!--
	This procedure extracts and prints information for all the services
	-->
	<xsl:template name="allServices">
		<xsl:for-each select="/trains/train">
			<xsl:call-template name="oneService">
				<xsl:with-param name="train" select="."/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!--
	This procedure extracts and prints information for one service
	-->
	<xsl:template name="oneService">
		<xsl:param name="train"/>

		<Service>
			<ServiceId><xsl:value-of select="$train/trainNo"/></ServiceId>

			<!-- Use default value defined in schema -->
			<Version>0</Version>

			<Direction>
				<xsl:variable name="dir" select="$train/direction"/>
				<xsl:choose>
				<xsl:when test="$dir = 'Up'">UP</xsl:when>
				<xsl:when test="$dir = 'Down'">DOWN</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$train/direction"/>
				</xsl:otherwise>
				</xsl:choose>
			</Direction>
			<Groups>
				<xsl:for-each select="$train/groups">
					<Group><xsl:value-of select="."/></Group>
				</xsl:for-each>
			</Groups>

			<xsl:call-template name="getStartStation">
				<xsl:with-param name="train" select="$train"/>
			</xsl:call-template>
			<EndStation>
				<Station>
					<xsl:variable name="cnt" select="count($train/object)"/>

					<xsl:call-template name="getEndStation">
						<xsl:with-param name="train" select="$train"/>
						<xsl:with-param name="count" select="$cnt"/>
					</xsl:call-template>
				</Station>
			</EndStation>

			<!--
			* DaysCode is extracted from the consist field of 1st trip.
			* If multiple trips exists and the days-code in those consist fields
			  do not match, it's the responsibilities of the user to validate
			  the data.
			* Only create this field if the consist field contains a days-code
			  i.e. has a forward slash.
			-->
			<xsl:if test="contains($train/consists, '/')">
				<DaysCode><xsl:value-of select="substring-after($train/consists, '/')"/></DaysCode>
			</xsl:if>

			<!-- Use default value defined in schema -->
			<PassengerWeightedMinutes>0</PassengerWeightedMinutes>

			<!-- For now, treat one train == one service == one trip -->
			<xsl:call-template name="oneTrip">
				<xsl:with-param name="train" select="$train"/>
			</xsl:call-template>
		</Service>
	</xsl:template>

	<!--
	This procedure extracts and prints information for one trip
	-->
	<xsl:template name="oneTrip">
		<xsl:param name="train"/>

		<Trip>
			<TripId><xsl:value-of select="$train/trainNo"/></TripId>

			<!-- Use default value defined in schema -->
			<Status>NOT_STARTED</Status>
			<ChangeStatus>
				<Stage>PLANNED</Stage>
			</ChangeStatus>
			<Acknowledged>true</Acknowledged>

			<!-- Use Z as default type for empty element -->
			<xsl:variable name="typ" select="$train/type"/>
			<Type>
				<xsl:choose>
				<xsl:when test="$typ">
					<xsl:value-of select="$typ"/>
				</xsl:when>
				<xsl:otherwise>Z</xsl:otherwise>
				</xsl:choose>
			</Type>

			<!-- Use Z as default consist for empty element -->
			<xsl:variable name="con" select="$train/consists"/>
			<PlannedConsists>
				<xsl:choose>
				<xsl:when test="$con">
					<xsl:choose>
					<xsl:when test="contains($con, '/')">
						<xsl:variable name="consCd" select="substring-before($con, '/')"/>
						<xsl:value-of select="normalize-space($consCd)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$con"/>
					</xsl:otherwise>
				</xsl:choose>
				</xsl:when>
				<xsl:otherwise>Z</xsl:otherwise>
				</xsl:choose>
			</PlannedConsists>

			<xsl:call-template name="getStartStation">
				<xsl:with-param name="train" select="$train"/>
			</xsl:call-template>

			<EndStation>
				<Station>
					<xsl:variable name="cnt" select="count($train/object)"/>

					<xsl:call-template name="getEndStation">
						<xsl:with-param name="train" select="$train"/>
						<xsl:with-param name="count" select="$cnt"/>
					</xsl:call-template>
				</Station>
			</EndStation>

			<xsl:if test="$train/formedby">
				<FormedBy>
					<xsl:for-each select="$train/formedby/trainNo">
						<TripId><xsl:value-of select="."/></TripId>
					</xsl:for-each>
				</FormedBy>
			</xsl:if>
			<xsl:if test="$train/willform">
				<WillForm>
					<xsl:for-each select="$train/willform/trainNo">
						<TripId><xsl:value-of select="."/></TripId>
					</xsl:for-each>
				</WillForm>
			</xsl:if>
			<xsl:call-template name="allRoutes">
				<xsl:with-param name="train" select="$train"/>
				<xsl:with-param name="idx" select="1"/>
				<xsl:with-param name="rteCnt" select="count($train//routes)"/>
				<xsl:with-param name="prevObjCnt" select="1"/>
				<xsl:with-param name="rteHdPos" select="1"/>
			</xsl:call-template>
		</Trip>
	</xsl:template>

	<!--
	This procedure extracts and prints information for all routes of one trip
	-->
	<xsl:template name="allRoutes">
		<xsl:param name="train"/>
		<xsl:param name="idx"/>
		<xsl:param name="rteCnt"/>
		<xsl:param name="prevObjCnt"/>
		<xsl:param name="rteHdPos"/>

		<xsl:if test="$idx &lt;= $rteCnt">
			<xsl:variable name="curObjCnt">
				<xsl:value-of select="count($rb/routes/route[routeId = $train/routes[$idx]]//routeObj)"/>
			</xsl:variable>
			<xsl:call-template name="oneRoute">
				<xsl:with-param name="train" select="$train"/>
				<xsl:with-param name="route" select="$train/routes[$idx]"/>
				<xsl:with-param name="routePos" select="$idx"/>
				<xsl:with-param name="rteHdPos" select="$rteHdPos"/>
			</xsl:call-template>
			<xsl:call-template name="allRoutes">
				<xsl:with-param name="train" select="$train"/>
				<xsl:with-param name="idx" select="$idx + 1"/>
				<xsl:with-param name="rteCnt" select="$rteCnt"/>
				<xsl:with-param name="prevObjCnt" select="$curObjCnt"/>
				<xsl:with-param name="rteHdPos" select="$rteHdPos + $curObjCnt - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!--
	This procedure extracts and prints information for one route.
	Note: Route is the term used in the txt format of the timetable provided
	      by DOI. In the final timetable XML schema, a route is called a path.
	-->
	<xsl:template name="oneRoute">
		<xsl:param name="train"/>
		<xsl:param name="route"/>
		<xsl:param name="routePos"/>
		<xsl:param name="rteHdPos"/>

		<Path>
			<PathId><xsl:value-of select="$route"/></PathId>
			<Group><xsl:value-of select="$train/groups"/></Group>
			<StopCode><xsl:value-of select="$train/stops[position()=$routePos]"/></StopCode>
			<xsl:call-template name="allGeoObjects">
				<xsl:with-param name="train" select="$train"/>
				<xsl:with-param name="routeid" select="$route"/>
				<xsl:with-param name="rteHdPos" select="$rteHdPos"/>
			</xsl:call-template>
		</Path>
	</xsl:template>

	<!--
	This procedure extracts and prints information for all geo objects of one route
	-->
	<xsl:template name="allGeoObjects">
		<xsl:param name="train"/>
		<xsl:param name="routeid"/>
		<xsl:param name="rteHdPos"/>

		<xsl:for-each select="$rb/routes/route[routeId = $routeid]/routeObj">
			<xsl:variable name="curPos" select="position()"/>
			<xsl:call-template name="oneGeoObject">
				<xsl:with-param name="train" select="$train"/>
				<xsl:with-param name="objcd" select="."/>
				<xsl:with-param name="pos" select="$rteHdPos + $curPos - 1"/>
			</xsl:call-template>
		</xsl:for-each>	
	</xsl:template>

	<!--
	This procedure extracts and prints information for one geo object
	-->
	<xsl:template name="oneGeoObject">
		<xsl:param name="train"/>
		<xsl:param name="objcd"/>
		<xsl:param name="pos"/>

		<GeoObject>
			<Object>
				<GeoObjectId><xsl:value-of select="$objcd"/></GeoObjectId>
				<GeoObject>
					<xsl:choose>
					<xsl:when test="starts-with($objcd, 'N') or starts-with($objcd, 'X')">
						<Platform>
							<Station><xsl:value-of select="substring($objcd, string-length($objcd)-2)"/></Station>
							<PlatformNumber><xsl:value-of select="substring($objcd, 2, 2)"/></PlatformNumber>
							<xsl:choose>
							<xsl:when test="starts-with($objcd, 'X')">
								<IsStationRoad>true</IsStationRoad>
							</xsl:when>
							<xsl:otherwise>
								<IsStationRoad>false</IsStationRoad>
							</xsl:otherwise>
							</xsl:choose>
						</Platform>
					</xsl:when>
					<xsl:otherwise>
						<Signal>
							<SignalNumber><xsl:value-of select="$objcd"/></SignalNumber>

							<xsl:variable name="inFile" select="boolean(count($rs//signal[.=$objcd]) &gt; 0)"/>
							<IsRouteSignal><xsl:value-of select="$inFile"/></IsRouteSignal>
						</Signal>
					</xsl:otherwise>
					</xsl:choose>		
				</GeoObject>
			</Object>

			<Arrives>
				<xsl:variable name="obj" select="$train/object[$pos]"/>
				<xsl:if test="$obj/code = $objcd">
					<xsl:call-template name="formatTime">
						<xsl:with-param name="time" select="$obj/arrives"/>
					</xsl:call-template>
				</xsl:if>
			</Arrives>

			<Departs>
				<xsl:variable name="obj" select="$train/object[$pos]"/>
				<xsl:if test="$obj/code = $objcd">
					<xsl:call-template name="formatTime">
						<xsl:with-param name="time" select="$obj/departs"/>
					</xsl:call-template>
				</xsl:if>
			</Departs>

		</GeoObject>
	</xsl:template>

	<!--
	This procedure converts the specified time from text format to XML-time
	format. If the time is after midnight i.e. it is 24, 25, 26 or 27, it is
	mapped back to a 24-hr cycle; and an element called "plus24Hour" with
	value "true" will be added.
	-->
	<xsl:template name="convertTime">
		<xsl:param name="time"/>

		<xsl:variable name="hh" select="substring($time, 1, 2)"/>
		<xsl:variable name="mm" select="substring($time, 3, 2)"/>
		<xsl:variable name="ss" select="substring($time, 5, 2)"/>
		<time><xsl:value-of select="$hh"/>:<xsl:value-of select="$mm"/>:<xsl:value-of select="$ss"/></time>
		<xsl:choose>
		<xsl:when test="$hh &gt; 23 and $hh &lt; 28"> 
			<time>0<xsl:value-of select="$hh - 24"/>:<xsl:value-of select="$mm"/>:<xsl:value-of select="$ss"/></time>
			<plus24Hour>true</plus24Hour>
		</xsl:when>
		<xsl:otherwise>
			<time><xsl:value-of select="$hh"/>:<xsl:value-of select="$mm"/>:<xsl:value-of select="$ss"/></time>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
	This procedure formats the specified time from text format ###### to ##:##:##
	-->
	<xsl:template name="formatTime">
		<xsl:param name="time"/>

		<xsl:variable name="hh" select="substring($time, 1, 2)"/>
		<xsl:variable name="mm" select="substring($time, 3, 2)"/>
		<xsl:variable name="ss" select="substring($time, 5, 2)"/>
		<time><xsl:value-of select="$hh"/>:<xsl:value-of select="$mm"/>:<xsl:value-of select="$ss"/></time>
	</xsl:template>

	<!--
	This procedure gets the first station in the object list i.e. the first object in the list that begins with
	'N' or 'X'
	-->
	<xsl:template name="getStartStation">
		<xsl:param name="train"/>

		<StartStation>
			<Station>
				<xsl:variable name="stncd" select="$train/object/code[starts-with(text(), 'N') or starts-with(text(), 'X')]"/>
				<xsl:value-of select="substring($stncd, string-length($stncd)-2)"/>
			</Station>
			<Departs>
				<xsl:call-template name="formatTime">
					<xsl:with-param name="time" select="$train/object[starts-with(code, 'N') or starts-with(code, 'X')]/departs"/>
				</xsl:call-template>
			</Departs>
		</StartStation>
	</xsl:template>

	<!--
	This procedure gets the last station in the object list i.e. the last object in the list that begins with
	'N' or 'X'
	-->
	<xsl:template name="getEndStation">
		<xsl:param name="train"/>
		<xsl:param name="count"/>

		<xsl:if test="$count &gt; 0">
			<xsl:variable name="objcd" select="$train/object[$count]/code[starts-with(text(), 'N') or starts-with(text(), 'X')]"/>
			<xsl:choose>
			<xsl:when test="$objcd">
				<xsl:value-of select="substring($objcd, string-length($objcd)-2)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="getEndStation">
					<xsl:with-param name="train" select="$train"/>
					<xsl:with-param name="count" select="$count - 1"/>
				</xsl:call-template>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
