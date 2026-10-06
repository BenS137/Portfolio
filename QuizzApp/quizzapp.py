import random,time,os
from PySide6.QtCore import QTimer,Qt, QUrl
from PySide6.QtWidgets import QApplication, QWidget, QVBoxLayout, QLabel, QStackedWidget, QMainWindow, QPushButton,QGridLayout
from PySide6.QtGui import QPainter, QColor
from PySide6.QtMultimedia import QMediaPlayer, QAudioOutput
from datetime import datetime

#Style für Antwortbuttons
CORRECT_STYLE = """
QPushButton {
    background-color: #4CAF50;
    color: white;
    font-weight: bold;
}
"""

WRONG_STYLE = """
QPushButton {
    background-color: #F44336;
    color: white;
    font-weight: bold;
}
"""

DEFAULT_STYLE = """
QPushButton {
    background-color: none;
    color: white;
}
"""
#Mögliche Fragen-Dateien
question_files = ["questions_info2.txt", "questions_nintendo.txt"]
#Zufällige Auswahl einer Datei
selected_file = random.choice(question_files)


def load_questions_txt(path):
    #Lese Fragen aus Textdatei,1 Frage und 4 Antworten
    with open(path, "r", encoding="utf8") as f:
        lines = [line.strip() for line in f.readlines() if line.strip()]

    questions = []

    #Immer 4 Zeilen pro Frage
    for i in range(1, len(lines), 5):
        question_text = lines[i]
        answers = lines[i+1:i+5]

        #richtige Antwort:
        correct_index = 0

        #fragen werden in dict gespeichert
        questions.append({
            "Frage": question_text,
            "Antworten": answers,
            "Richtig": correct_index
        })

    return questions
def load_topic(path):
    #Topic lesen
    with open(path, "r", encoding="utf8") as f:
        for line in f:
            line = line.strip()
            if line:  # Zeile ist nicht leer
                return line.split()[0]  # erstes Wort der ersten Zeile
#Test
# Zufällige Auswahl einer Datei
selected_file = random.choice(question_files)
# Fragen und Topic laden
questions = load_questions_txt(selected_file)
topic = load_topic(selected_file)


HIGHSCORE_FILE = "highscores.txt"

def load_highscores():
    highscores = []

    try:
        with open(HIGHSCORE_FILE, "r", encoding="utf8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue

                score, time_, topic, date = line.split(";")

                highscores.append({
                    "score": int(score),
                    "time": int(time_),
                    "topic": topic,
                    "date": date
                })
    except FileNotFoundError:
        pass

    return highscores
def save_highscore(score, total_time, topic):
    #Speichert Highscore in TXT und behält nur Top 10
    date = datetime.now().strftime("%Y-%m-%d %H:%M")

    # Alte Highscores laden
    highscores = load_highscores()
    highscores.append({
        "score": score,
        "time": total_time,
        "topic": topic,
        "date": date
    })

    #Sortieren: Score absteigend, Zeit aufsteigend
    highscores.sort(key=lambda x: (-x["score"], x["time"]))

    #Nur Top 10 behalten
    highscores = highscores[:10]

    #Datei neu schreiben
    with open(HIGHSCORE_FILE, "w", encoding="utf8") as f:
        for h in highscores:
            f.write(f"{h['score']};{h['time']};{h['topic']};{h['date']}\n")

class QuestionTimerIndicator(QWidget):
    #Fortschrittsbalken für verbleibende Zeit pro Frage
    def __init__(self, total_time=5):
        super().__init__()
        self.total_time = total_time #Sekunden pro Frage
        self.elapsed_time = 0
        self.setMinimumHeight(30)

    def reset(self):
        self.elapsed_time = 0
        self.update()

    def set_elapsed(self, seconds):
        #Fortschritt aktualisieren
        self.elapsed_time = seconds
        self.update()  # neu zeichnen

    def paintEvent(self, event):
        #Visualisierung
        painter = QPainter(self)
        w = self.width()
        h = self.height()-75
        
        # Hintergrund
        painter.setBrush(QColor("lightgray"))
        painter.setPen(Qt.NoPen)
        painter.drawRect(0, 0, w, h)

        # Fortschritt
        progress_width = int(w * (1 - self.elapsed_time / self.total_time))
        painter.setBrush(QColor("green"))
        painter.drawRect(0, 0, progress_width, h)

class ScoreCircles(QWidget):
    #Punkte Indikator
    def __init__(self, total=10):
        super().__init__()
        self.total = total       # Gesamtzahl der Fragen
        self.score = 0           # aktuelle Punktzahl
        self.setMinimumHeight(50)

    def set_score(self, score):
        #Aktualisiere Score
        self.score = score
        self.update()  # neu zeichnen

    def paintEvent(self, event):
        #Zeichne Kreise für jeden Punkt
        painter = QPainter(self)
        radius = 25
        spacing = 50
        total_circles = self.total
        total_width = total_circles * (2*radius) + (total_circles-1)*spacing
        start_x = (self.width() - total_width) // 2
        y = self.height() -90

        for i in range(total_circles):
            x = start_x + i*(2*radius + spacing)
            painter.setBrush(QColor("green") if i < self.score else QColor("lightgray"))
            painter.setPen(Qt.black)
            painter.drawEllipse(x, y-radius, 2*radius, 2*radius)
                
#Startseite
class StartScreen(QWidget):
    #Zeigt Begrüßung, Regeln und Startbutton
    def __init__(self, stack: QStackedWidget):
        super().__init__()
        layout = QVBoxLayout()

        #Begrüßung
        self.introduction=(QLabel("Willkommen zur QuizzApp" ))
        layout.addWidget(self.introduction)

        font = self.introduction.font()
        font.setPointSize(60)
        #font.setBold(True)
        self.introduction.setFont(font)
        self.introduction.setAlignment(Qt.AlignCenter)


        #Regeln
        self.titel=QLabel("Spielregeln:")
        layout.addWidget(self.titel)
        font_titel=self.titel.font()
        font_titel.setPointSize(30)
        self.titel.setFont(font_titel)
        self.regeln=QLabel("     1) Nachdem Sie auf Start drücken geht das Spiel los \n     2) Sie haben fünf Sekunden Zeit um die Frage zu beantworten \n     3) Solltten Sie falsch oder zu spät Antworten endet das Spiel bevor Sie alle Fragen gesehen haben \n     4) Wenn Sie alle Fragen richtig beantworten haben Sie gewonnen! ")
        layout.addWidget(self.regeln,alignment=Qt.AlignCenter)
        font_regeln=self.regeln.font()
        font_regeln.setPointSize(20)
        self.regeln.setFont(font_regeln)
        
        #StartButton
        start_btn = QPushButton("Start")
        #Wenn clickt starte quiz und wechsel das widget
        start_btn.clicked.connect(lambda: self.start_and_switch(stack))
        layout.addWidget(start_btn)
        self.setLayout(layout)

    def start_and_switch(self, stack):
        #Wechsel zu QuizScreen und startet das Quiz
        quiz_screen = stack.widget(1)
        quiz_screen.start_quiz()   #Timer starten & erste Frage laden
        stack.setCurrentIndex(1)

class QuizScreen(QWidget):
    #Quizbildschirm mit Fragen, Timer, Score und Audio
    def __init__(self, questions, stack, result_screen):
        super().__init__()
        self.stack = stack
        self.result_screen = result_screen
        self.questions = questions
        self.current_index = 0
        self.score = 0
        self.total_questions = len(self.questions)
        self.score_widget = ScoreCircles(total=len(self.questions))
        self.question_timer_widget = QuestionTimerIndicator(total_time=5)

        #Audioausgaben erzeugen
        self.audio_output_correct = QAudioOutput()
        self.audio_output_wrong = QAudioOutput()
        self.audio_output_timeout = QAudioOutput()

        #Player richtige Antwort
        self.correct_sound = QMediaPlayer()
        self.correct_sound.setAudioOutput(self.audio_output_correct)
        self.correct_sound.setSource(
            QUrl.fromLocalFile(os.path.abspath("sounds/correct.mp3"))
        )
        self.audio_output_correct.setVolume(0.5)

        #Player falsche Antwort
        self.wrong_sound = QMediaPlayer()
        self.wrong_sound.setAudioOutput(self.audio_output_wrong)
        self.wrong_sound.setSource(
            QUrl.fromLocalFile(os.path.abspath("sounds/wrong.mp3"))
        )
        self.audio_output_wrong.setVolume(0.5)


        #Timer für Spielzeit
        self.game_timer = QTimer(self)
        self.game_timer.timeout.connect(self.update_game_timer)
        # alle 1 Sekunde

        #Timer für Frage
        self.question_duration = 5  #Sekunden pro Frage
        self.question_timer = QTimer(self)
        self.question_timer.setSingleShot(True)
        self.question_timer.timeout.connect(self.time_up_for_question)

        self.question_timer_widget.total_time = self.question_duration

        layout = QVBoxLayout()
        layout.addWidget(self.score_widget)

        layout.addWidget(self.question_timer_widget)
        self.question_timer_interval = 50  #50ms
        self.question_elapsed = 0

        self.question_timer_fine = QTimer(self)
        self.question_timer_fine.timeout.connect(self.update_question_timer)
        #Topic
        self.topic_label=QLabel()
        layout.addWidget(self.topic_label)
        #Frage
        self.question_label = QLabel()
        layout.addWidget(self.question_label)

        #Antwortbuttons
        self.answer_buttons = []

        grid = QGridLayout()
        grid.setSpacing(15)

        for i in range(4):
            btn = QPushButton()
            btn.setMinimumHeight(60)
            btn.clicked.connect(self.handle_answer)
            self.answer_buttons.append(btn)
            grid.addWidget(btn, i // 2, i % 2)  # 2x2

        layout.addLayout(grid)
        self.setLayout(layout)

    def start_quiz(self):
        self.total_time=0
        self.load_question()                 #Erste Frage laden
        self.game_timer.start(1000)          #Spielzeit-Timer starten
        self.question_timer_fine.start(self.question_timer_interval)  # Fine-Timer starten    
    def update_game_timer(self):
         self.total_time += 1

    def load_question(self):
        q = self.questions[self.current_index]

        self.start_time = time.time()  #Absolute Startzeit für visuellen Timer
        self.question_elapsed = 0

        self.question_timer_widget.reset()
        self.question_timer_widget.total_time = self.question_duration

        self.question_timer_fine.start(self.question_timer_interval)  # Fine-Timer starten
        self.question_timer.start(self.question_duration * 1000)      # SingleShot-Timer starten
        
        self.topic_label.setText(topic)
        font = self.topic_label.font()
        font.setPointSize(40)
        self.topic_label.setFont(font)

        #stelle Frage
        self.question_label.setText(q["Frage"])
        # Schriftgröße der Frage z.B. größer machen
        font = self.question_label.font()
        font.setPointSize(25)
        #font.setBold(True)
        self.question_label.setFont(font)
        self.question_label.setAlignment(Qt.AlignCenter)

        #Antworten mischen, Originalindex merken
        answers = list(enumerate(q["Antworten"]))
        random.shuffle(answers)

        self.correct_button_index = None

        for btn, (orig_idx, text) in zip(self.answer_buttons, answers):
            btn.setText(text)
            btn.setEnabled(True)
            btn.setStyleSheet(DEFAULT_STYLE)#Reset

            btn.setProperty("is_correct", orig_idx == q["Richtig"])  
    
    
    def time_up_for_question(self):

        self.question_timer_fine.stop()
        self.question_timer.stop()

        #Buttons sperren
        for btn in self.answer_buttons:
            btn.setEnabled(False)

        #richtige Antwort markieren
        for btn in self.answer_buttons:
            if btn.property("is_correct"):
                btn.setStyleSheet(CORRECT_STYLE)
    
        self.current_index = len(self.questions)
        QTimer.singleShot(2000, self.next_step)
    
    def update_question_timer(self):
        #Fine-Timer Update
        self.question_elapsed = time.time() - self.start_time  # exakte vergangene Zeit
        self.question_timer_widget.set_elapsed(self.question_elapsed)
    
        if self.question_elapsed >= self.question_timer_widget.total_time:
            self.question_timer_fine.stop()
            if self.question_timer.isActive():
                self.time_up_for_question()
    def handle_answer(self):
        #Antwort auswerten
        clicked_btn = self.sender()
        is_correct = clicked_btn.property("is_correct")

        self.question_timer.stop()
        self.question_timer_fine.stop()

        for btn in self.answer_buttons:
            btn.setEnabled(False)
        #Buttons einfärben
        for btn in self.answer_buttons:
            if btn.property("is_correct"):
                btn.setStyleSheet(CORRECT_STYLE)
            elif btn == clicked_btn:
                btn.setStyleSheet(WRONG_STYLE)

        if is_correct:
            self.correct_sound.stop()  #stoppt, falls noch aktiv
            self.correct_sound.play()

            self.score += 1
            self.score_widget.set_score(self.score)
            #zur nächsten Frage wechseln
            self.current_index += 1
        else:
            self.wrong_sound.stop()
            self.wrong_sound.play()

            self.current_index = len(self.questions)
        #Kurze Pause, dann nächste Frage       
        QTimer.singleShot(2000, self.next_step)

        
    def next_step(self):

        if self.current_index < len(self.questions):
            self.load_question()
            
            
        else: #update punkte und wechsel auf endseite
            self.result_screen.update_score(self.score,self.total_time)
            self.stack.setCurrentWidget(self.result_screen)
            self.game_timer.stop()
        
    def reset_quiz(self):
        self.game_timer.stop()
        self.question_timer.stop()
        self.question_timer_fine.stop()

        self.current_index = 0
        self.score = 0
        self.total_time=0

        self.score_widget.set_score(0)       
        self.question_timer_widget.reset()
        
        self.load_question()
        
    
class ResultScreen(QWidget):
    #zeigt Punktzahl, Meldung, Leaderboard-Button, Neustart-Button
    def __init__(self,stack):
        super().__init__()
        self.end_score_widget = ScoreCircles(10)
        layout = QVBoxLayout()
        layout.addWidget(self.end_score_widget)
        
        self.meldung=QLabel()
        layout.addWidget(self.meldung)
        font_meldung = self.meldung.font()
        font_meldung.setPointSize(40)
        font_meldung.setBold(True)
        self.meldung.setFont(font_meldung)
    
        
        
        self.score_label = QLabel()
        layout.addWidget(self.score_label)
        font=self.score_label.font()
        font.setPointSize(30)
        self.score_label.setFont(font)

        self.leaderboard_btn = QPushButton("Leaderboard")
        layout.addWidget(self.leaderboard_btn)

        self.restart_btn = QPushButton("Neustart")
        layout.addWidget(self.restart_btn)

        self.setLayout(layout)

        
    def update_score(self, score, total_time):
        #Zeigt Ergebnis und speichert Highscore
        save_highscore(score, total_time, topic)
        
        # Score anzeigen
        self.end_score_widget.set_score(score)
        if score<10:
            self.meldung.setText("Danke bis Hierher!")
        else:
            self.meldung.setText("Gratulation!")
        self.score_label.setText(f"Du hast {score} von 10 Fragen in {total_time} Sekunden richtig beantwortet")
    
class LeaderboardScreen(QWidget):
    #Zeigt Top 10 Highscores
    def __init__(self, stack):
        super().__init__()
        self.stack = stack

        layout = QVBoxLayout()

        title = QLabel("Highscores")
        title.setAlignment(Qt.AlignCenter)
        title.setStyleSheet("font-size: 36px; font-weight: bold;")
        layout.addWidget(title)

        self.entries_layout = QVBoxLayout()
        layout.addLayout(self.entries_layout)

        back_btn = QPushButton("Zurück")
        back_btn.clicked.connect(lambda: stack.setCurrentIndex(2))
        layout.addWidget(back_btn)

        self.setLayout(layout)

    def refresh(self):
        #Alte Einträge löschen, Highscores laden, Top 10 anzeigen
        while self.entries_layout.count():
            item = self.entries_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()

        highscores = load_highscores()
        highscores.sort(key=lambda x: (-x["score"], x["time"]))

        if not highscores:
            self.entries_layout.addWidget(QLabel("Noch keine Highscores"))
            return

        for i, h in enumerate(highscores[:10], start=1):
            lbl = QLabel(
                f"{i}. {h['score']} Punkte - {h['time']}s - {h['topic']} - {h['date']}"
            )
            lbl.setStyleSheet("font-size: 18px;")
            self.entries_layout.addWidget(lbl)

class App(QMainWindow):
    #Erstellt Stack, alle Screens, verbindet Buttons
    def __init__(self):
        super().__init__()
        self.stack = QStackedWidget()


        #Screens erstellen
        self.result_screen = ResultScreen(self.stack)
        self.quiz_screen = QuizScreen(questions, self.stack,self.result_screen)
        self.start_screen = StartScreen(self.stack)
        self.leaderboard_screen = LeaderboardScreen(self.stack)
        
        #Screens zum Stack hinzufügen
        self.stack.addWidget(self.start_screen)   # index 0
        self.stack.addWidget(self.quiz_screen)    # index 1
        self.stack.addWidget(self.result_screen)  # index 2
        self.stack.addWidget(self.leaderboard_screen)  # index 3

        #Buttons verbinden
        self.result_screen.restart_btn.clicked.connect(self.restart_quiz)
        self.result_screen.leaderboard_btn.clicked.connect(lambda: self.show_leaderboard())

        self.setCentralWidget(self.stack)

    def show_leaderboard(self):
        self.leaderboard_screen.refresh()
        self.stack.setCurrentWidget(self.leaderboard_screen)

    def restart_quiz(self):
        self.quiz_screen.reset_quiz()
        self.stack.setCurrentIndex(0)  # zurück zum Quiz
#Start
app = QApplication([])
window = App()
window.resize(1200,800)
window.show()
app.exec()