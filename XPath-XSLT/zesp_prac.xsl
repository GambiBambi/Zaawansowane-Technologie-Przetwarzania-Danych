<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:template match="/">
        <html>
            <body>
                <h1>ZESPOŁY:</h1>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="/">
        <html>
            <body>
                <h1>ZESPOŁY:</h1>
                <ol>
                    <xsl:for-each select="ZESPOLY/ROW">
                        <li>
                            <xsl:value-of select="NAZWA"/>
                        </li>
                    </xsl:for-each>
                </ol>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="/">
        <html>
            <body>
                <h1>ZESPOŁY:</h1>
                <ol>
                    <xsl:apply-templates select="ZESPOLY/ROW"/>
                </ol>
                <div>
                    <xsl:apply-templates select="ZESPOLY/ROW" mode="details"/>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="ROW">
        <li>
            <xsl:value-of select="NAZWA"/>
        </li>
    </xsl:template>
    <xsl:template match="ROW" mode="details">
        <p>
            <strong id="{ID_ZESP}"><xsl:value-of select="NAZWA"/></strong><br/>
            <strong><xsl:value-of select="ADRES"/></strong>
            <xsl:variable name="HowManyEmployees" select="count(PRACOWNICY/ROW[ID_ZESP = current()/ID_ZESP])"/>
            <xsl:if test="$HowManyEmployees > 0">
                <table border="1">
                    <tr>
                        <th>Nazwisko</th>
                        <th>Etat</th>
                        <th>Zatrudniony</th>
                        <th>Placa podstawowa</th>
                        <th>Szef</th>
                    </tr>
                    <xsl:apply-templates select="PRACOWNICY/ROW" mode="employee_details" >
                        <xsl:sort select="NAZWISKO" />
                    </xsl:apply-templates>
                </table>
            </xsl:if>
            <xsl:if test="$HowManyEmployees = 0">
                <br/><br/>
            </xsl:if>
            Liczba pracowników: <xsl:value-of select="count(PRACOWNICY/ROW[ID_ZESP = current()/ID_ZESP])"/>
        </p>
    </xsl:template>
    <xsl:template match="ROW/PRACOWNICY/ROW" mode="employee_details">
        <tr>
            <td><xsl:value-of select="NAZWISKO"/></td>
            <td><xsl:value-of select="ETAT"/></td>
            <td><xsl:value-of select="ZATRUDNIONY"/></td>
            <td><xsl:value-of select="PLACA_POD"/></td>
            <td>
                <xsl:choose>
                    <xsl:when test="ID_SZEFA">
                        <xsl:value-of select="//ROW/PRACOWNICY/ROW[ID_PRAC = current()/ID_SZEFA]/NAZWISKO"/>
                    </xsl:when>
                    <xsl:otherwise>brak</xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="ROW">
        <xsl:if test="NAZWA != ''">
            <li>
                <a href="#{ID_ZESP}">
                    <xsl:value-of select="NAZWA"/>
                </a>
            </li>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>